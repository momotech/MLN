---
--- 使用Android/iOS数据绑定
---
--- BindMeta.lua
--- Created by sun.
--- DateTime: 2020-05-25 19:18
--- 版本号 每次修改完内容后需要自动增加版本号/或者保证不会影响老版本
--- @version 1.1

local __get = "__get"
local __path = "__path"
local __ishook = "__ishook"
local __kvoname = "__kvoname" -- path
local __set = "__set"
local __asize = "__asize" --获取数组大小
local __vv = "__vv" -- 实际存的值
local __ignore = "__ignore" -- watch忽略
local __ci = "__ci" -- cell item
local __cii = "__cii"

---
--- 只监听lua端修改值引起的变化
watch_from_native = function(context) return context == WatchContext.NATIVE  end

---
--- 只监听native端修改值引起的变化
watch_from_lua = function(context) return context == WatchContext.LUA  end

---
--- 只监听native与lua端修改值引起的变化
watch_all = function() return true end

local __OperationType = {
    WT_normal = 1, -- __watch1 / watchAction -- 普通watch 监听最后一个key的值变化 a.b.c 只有c变化时才走回调
    WT_value  = 2, -- __watchValue -- a.b.c b/c的变化走会走回调
    WT_all    = 3, -- __watchAll -- 同时监听lua与原生的变化
    WT_end    = 4,
    ------ 分割线 -------
    OP_remove = 10, -- __remove
    OP_rreal  = 11, -- __rreal -- 移除缓存
    OP_greal  = 12, -- __greal -- 获取值并缓存
}

-- get操作转为call
local __getToCallOPs = {}
__getToCallOPs["__watch1"] = __OperationType.WT_normal
__getToCallOPs["__watch"] = __OperationType.WT_normal
__getToCallOPs["__watchValue"] = __OperationType.WT_value
__getToCallOPs["__watchValueAll"] = __OperationType.WT_all
__getToCallOPs["__remove"] = __OperationType.OP_remove
__getToCallOPs["__rreal"] = __OperationType.OP_rreal
__getToCallOPs["__greal"] = __OperationType.OP_greal

-- debug
--local __ck = "__ck" -- 当前key
--local __pk = "__pk" -- 前一个key
--local __bt = "__bt"
local WATCH = "watch" -- prevew中使用
local FOREACH = "forEach"
local __b_G = "G_G"
local __b_G_ = "G_G."
local __b_G_l = string.len(__b_G_)
local __use_gg = false ---是否前置添加G_G 现默认不填了

local _kpathCache = {} -- {path = MetaTab }
local _watchCache = {} -- {watchid1 = {path, func1}, watchid2 = {path, func2}, ...}
local _debugpwacths = {} --preview {path = {func1, funct2, ...}}
local _ckeyTabCaches = {} -- ckey对应缓存
local _cellBinds = {} -- list cell binds
local _foreachCaches = {} -- 用于foreach中的缓存

if debug_preview_open == nil then
    debug_preview_open = false
end
if debug_preview_watch == nil then
    debug_preview_watch = false
end
if __open_combine_data__ == nil then
    __open_combine_data__ = true --- 开启list cell 一次性获取全部item数据
end
if __open_cell_data__ == nil then
    __open_cell_data__ = false --- 是否开启cell data 获取方法
end
if __open_use_set_cache__ == nil then --- 是否使用数据缓存
    __open_use_set_cache__ = true
end

-- 创建弱引用表
function createWeakT(mode) --"k" / "v" / "kv"
    return setmetatable({}, { __mode = mode})
end

-------
--- function def
----
local bindMeta_setmetable
local bindMeta_push
local bindMeta_pop
local bindMeta_get
local bindMeta_add

-------------------------------------------------------------------------------------------------------------
------------- 空表初始化               --------------------------
-----------------------------------------------------------------------------------------------------------
local _emptyTab = {}
setmetatable(_emptyTab, {
    __index = function(_, k)
        if k == __get then return nil end
        if k == __asize then
            if __open_use_set_cache__ then
                bindMeta_push(_foreachCaches)
            end
            return 0
        end
        if k == __path then return "" end
        return _emptyTab
    end,
    __newindex = function() end,
    __ishook = true,
    __kvoname = "",
    __ck = "",
    __pk = "",
    __vv = nil,
})
-------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
local rowSectionMeta = {
    __index = function(t) return t end,
    __call = function()  end
}
local function bindMeta_rowOrSection(value)
    return setmetatable({ __get = value}, rowSectionMeta)
end

-- 用于缓存值不统一引起的 - list时 一维二维相互转换引起key不同
local __e_ = {}
local function bindMeta_ckeyGet(cKey)
    if cKey == nil then return __e_ end
    return _ckeyTabCaches[cKey] or __e_
end
local function bindMeta_ckeyPut(cKey, mt)
    if cKey == nil then return end
    if _ckeyTabCaches[cKey] == nil then
        _ckeyTabCaches[cKey] = createWeakT("k")
    end
    _ckeyTabCaches[cKey][mt] = true
end


--- 拼接 path -
local function bindMeta_path(k1, k2, force)
    -- preview模式下会前面会多个 G. 所以需要删除
    if k1 == nil then
        return k2 or ""
    end
    if __use_gg and (force or (debug_preview_open == false and debug_preview_watch)) then
        if string.len(k1) > __b_G_l and string.sub(k1, 1, __b_G_l) == __b_G_ then
            k1 = string.sub(k1, __b_G_l + 1)
        end
    end
    if k2 then
        return k1 .. "." .. k2
    end
    return k1
end

--- 批量设置元表 -- 不做上下文连接
local function bindMeta_batchSetMeta(t, path, ck, pk)
    for _k, _v in pairs(t) do
        if type(_v) == "table" then
            bindMeta_batchSetMeta(_v, bindMeta_path(path , _k), _k, ck)
        else
            BindMeta(bindMeta_path(path , _k), {}, _v, _k, ck, true)
        end
    end
    return BindMeta(bindMeta_path(path), {}, t, ck, pk, true)
end

local function bindMeta_getAndCacheTab(mt, isCache, isCell)
    if __open_use_set_cache__ then
        bindMeta_push(_foreachCaches)
    end
    local t = mt.__vv
    if isCache and t ~= nil then
        if mt.__bt then return t end
    else
        if isCell and __open_cell_data__ then
            local bind = string.sub(mt.__kvoname, 1,
                    #mt.__kvoname - #(tostring(mt.__pk) .. tostring(mt.__ck)) - 2)
            local section = mt.__pk
            if type(section) == "number" then
                bind = string.sub(mt.__kvoname, 1,
                        #mt.__kvoname - #(tostring(section) .. tostring(mt.__ck)) - 2)
            else
                bind = string.sub(mt.__kvoname, 1,
                        #mt.__kvoname - #(tostring(mt.__ck)) - 1)
                section = 1
            end
            t = DataBinding:getCellData(bind, section, mt.__ck)
        else
            t = DataBinding:get(bindMeta_path(mt.__kvoname))
        end
    end

    if __open_use_set_cache__ and t and type(t) == "table" then
        bindMeta_batchSetMeta(t, bindMeta_path(mt.__kvoname), mt.__ck, mt.__pk)
    else
        BindMeta(bindMeta_path(mt.__kvoname), nil, t, mt.__ck, mt.__pk, true)
    end
    return t
end

--- 数组获取
local function bindMeta_getArraySize(mt)
    local t = bindMeta_getAndCacheTab(mt, true)
    if t == nil then return 0 end
    return #t
end

local function bindMeta_getWatchPath(keypath, ck)
    if type(ck) == "number" then
        local pt = _kpathCache[string.sub(keypath, 1,#keypath - #tostring(ck) -1)]
        if pt then
            local mt = getmetatable(pt)
            return bindMeta_getWatchPath(mt.__kvoname, mt.__ck)
        end
    end
    return keypath
end

local function bindMeta_update(path, v, cKey, pmt)
    if pmt then pmt.__vv = nil end
    for _v, _ in pairs(bindMeta_ckeyGet(cKey)) do --同属性key修改先置为空 - 使用时需要本地读取
        _v.__vv = nil
    end
    DataBinding:update(path, v)
end

local function bindMeta_watch(mt, v, operation, filter)
    local k = bindMeta_path(bindMeta_getWatchPath(mt.__kvoname, mt.__ck))
    if k == nil then return end
    local w_id
    if operation == __OperationType.WT_normal then
        if filter then
            w_id = DataBinding:watch(k, filter, v)
        else
            w_id = DataBinding:watch(k, v)
        end
    elseif operation == __OperationType.WT_value then
        if filter then
            w_id = DataBinding:watchValue(k, filter, v)
        else
            w_id = DataBinding:watchValue(k, v)
        end
    elseif operation == __OperationType.WT_all then
        w_id = DataBinding:watchValueAll(k, v)
    end
    if w_id then
        _watchCache[w_id] = {k, v}
    end
    return w_id
end

local function bindMeta_cacheSet(mt, path, v)
    if __open_use_set_cache__ then
        mt.__vv = v
        bindMeta_get(_foreachCaches)[path] = true
    end
end

--- 存储 list 数据绑定path
local function bindMeta_setCellPath(path, mt)
    if bindMeta_get(_cellBinds) then
        if type(mt.__ck) == "number" then
            path = string.sub(path, 1, #path - #tostring(mt.__ck) - 1)
        end
        bindMeta_add(_cellBinds, path, true)
    end
end

-----------------------------------------------------------------------------------------------------------
----------------------  原表操作  __index/__newindex/__call                --------------------------
-----------------------------------------------------------------------------------------------------------
-- __index
local function bindMeta__index(t, k)
    if k == nil then
        return _emptyTab
    end
    if type(k) == "table" then
        k = k.__get
    elseif type(k) == "number" and k <= 0 then
        return _emptyTab
    end
    if k == "-1" then
        return t
    end

    local mt = getmetatable(t)
    if k == __kvoname or k == __ishook then
        return mt[k]
    end
    if k == __vv then
        return mt.__vv
    end
    --print("to Get::" .. mt.__kvoname, k)
    if k == __get then -- get
        local temp_path = bindMeta_path(mt.__kvoname)
        bindMeta_setCellPath(temp_path, mt)
        local temp_v = mt.__vv
        if temp_v ~= nil then return temp_v end -- 有缓存先使用缓存内容
        --print("to Get::" .. mt.__kvoname, k)
        temp_v = DataBinding:get(temp_path)
        if (#_foreachCaches) > 0 then
            bindMeta_cacheSet(mt, temp_path, temp_v)
        end
        return temp_v
    elseif k == __path then
        return bindMeta_path(mt.__kvoname)
    elseif k == __asize then
        --return DataBinding:arraySize(bindMeta_path(mt.__kvoname)) or 0
        return bindMeta_getArraySize(mt)
    elseif __getToCallOPs[k] then
        mt.__opname = k
        return t
    elseif k == __ci or k == __cii then
        local temp_v
        local section = type(mt.__pk) == "number" and mt.__pk or 1
        if k == __ci then
            ---@see BindMetaWatchListCell() -- 结束
            bindMeta_push(_cellBinds)
            if __open_combine_data__ then
                temp_v = bindMeta_getAndCacheTab(mt, false, true)
            end
        end
        return BindMeta(bindMeta_path(mt.__kvoname),
                {row=bindMeta_rowOrSection(mt.__ck), section={__get=bindMeta_rowOrSection(section)}},
                temp_v, mt.__ck, mt.__pk)
    end
    if debug_preview_watch then
        if k == WATCH or k == FOREACH then
            mt.__opname = k
            return t
        end
    end
    return BindMeta(bindMeta_path(mt.__kvoname,  k), nil, nil, k, mt.__ck)
end

-- __newindex
local function bindMeta__newindex(t, k, v)
    if k == nil or k == __vv or k == __ignore then return end
    local mt = getmetatable(t)
    local operation = __getToCallOPs[k] or 0
    if operation > 0 and operation < __OperationType.WT_end then -- watch
        bindMeta_watch(mt, v, operation)
        return
    end

    if k == __set then k = nil end

    if debug_preview_open then
        rawset(t, k, v)
        if type(v) == "table" then
            --- 自动添加原表
            local meta = BindMeta(bindMeta_path(mt.__kvoname , k), v, nil, k, mt.__ck)
            for _k, _v in pairs(v) do
                bindMeta__newindex(meta, _k, _v)
            end
        end
        return
    end

    local path = bindMeta_path(mt.__kvoname, k)
    if debug_preview_watch then
        -- mock顶层数据
        if __use_gg and mt.__kvoname == __b_G then
            DataBinding:mock(k, v)
            for _, _t in pairs(_watchCache) do
                _t[2](DataBinding:get(_t[1]), nil)
            end
            return
        end
        if type(v) == "table" and v.__ishook then
            v = v.__get
        end
        bindMeta_update(path, v, k, mt)
        for _, __f in pairs(_debugpwacths[path] or {}) do
            __f(v)
        end
        return
    end
    bindMeta_update(path, v, k, mt)
end

-- __call
local function bindMeta__call(t, ...)
    local mt = getmetatable(t)
    local op = mt.__opname
    if not op then
        assert(true, "bind meta call error...")
        return
    end
    mt.__opname = nil

    local operation = __getToCallOPs[op] or 0

    if operation == __OperationType.OP_greal then -- bind中缓存相关
        bindMeta_getAndCacheTab(mt, false)
        return
    end
    if operation == __OperationType.OP_rreal then
        BindMetaPopForach()
        return
    end

    local size = select("#", ...)
    if size == 0 then
        return
    end

    local p1 = select(1, ...)
    if operation == __OperationType.OP_remove then
        -- remove watch
        for _id, _t in pairs(_watchCache) do
            if _t[2] == p1 then
                DataBinding:removeObserver(_id)
                _watchCache[_id] = nil
            end
        end
        return
    elseif operation > 0 and operation < __OperationType.WT_end then
        local filter = nil
        if size == 2 then
            filter = p1
            p1 = select(2, ...)
        end
        return bindMeta_watch(mt,p1, operation, filter)
    end

    if debug_preview_watch then
        if size == 2 and op == WATCH then
            -- debug prevew watch
            local k = bindMeta_path(mt.__kvoname,  p1, true)
            local v = _debugpwacths[k]
            if not v then
                v = {}
                _debugpwacths[k] = v
            end
            v[#v + 1] = select(2, ...)
        elseif size == 1 and op == FOREACH then
            for __k, __v in pairs(t) do
                p1(__v, __k)
            end
        end
    end
end

bindMeta_setmetable = function(o, kpath, v, cKey, preKey, batch)
    _kpathCache[kpath] = o
    local meta = getmetatable(o)
    local mt = {
        __index = bindMeta__index,
        __newindex = bindMeta__newindex,
        __call = bindMeta__call,
        __ishook = true,
        __kvoname = kpath,
        __mt = meta,
        __ck = cKey,
        __pk = preKey,
        __vv = v,
        __bt = batch,
    }
    if not __open_use_set_cache__ then
        mt.__vv = nil
    end
    setmetatable(o, mt)
    if (#_foreachCaches) > 0 then
        bindMeta_get(_foreachCaches)[kpath] = true
    end
    bindMeta_ckeyPut(cKey, mt)
end
-------------------------------------------------------------------------------------------------------------
------------------------------         hook table insert/remove                 --------------------------
-----------------------------------------------------------------------------------------------------------
if hook_table_insert == nil then
    hook_table_insert = table.insert
    table.insert = function(t, ...)
        assert(t, "insert table must not be nil ")
        if debug_preview_open == false and t.__ishook then
            if select('#', ...) == 1 then
                DataBinding:insert(bindMeta_path(t.__kvoname), -1, select(1, ...))
                return
            end
            DataBinding:insert(bindMeta_path(t.__kvoname), select(1, ...), select(2, ...))
            return
        end
        hook_table_insert(t, ...)
    end
    hook_table_remove = table.remove
    table.remove = function(t, ...)
        assert(t, "remove table must not be nil ")
        if debug_preview_open == false and t.__ishook then
            if select('#', ...) == 0 then
                DataBinding:remove(bindMeta_path(t.__kvoname), -1)
                return
            end
            DataBinding:remove(bindMeta_path(t.__kvoname), select(1, ...))
            return
        end
        hook_table_remove(t, ...)
    end
end
-------------------------------------------------------------------------------------------------------------
--------------------------------         主入口方法  初始化                 --------------------------
-------------------------------------------------------------------------------------------------------------
---@param kpath string path
---@param o table 初始化对象
---@param v void  model默认值
---@param cKey string/number 当前keypath
---@param preKey string/number 上一级keypath
---@param batch boolean 是否是批量修改的meta
function BindMeta(kpath, o, v, cKey, preKey, batch)
    kpath = kpath or ""
    if o then
        if not o.__ishook then
            bindMeta_setmetable(o, kpath, v, cKey, preKey, batch)
        end
        return o
    end
    o = _kpathCache[kpath]
    if o == nil then
        o = {}
        bindMeta_setmetable(o, kpath, v, cKey, preKey, batch)
    end
    return o;
end
----------------------------------------------------------------------------------------------------------
----------------------------         清空操作                       --------------------------
---------------------------------------------------------------------------------------------------------
function BindMetaClear()
    _kpathCache = {}
    _debugpwacths = {}
    for _id, _ in pairs(_watchCache) do
        DataBinding:removeObserver(_id)
    end
    _watchCache = {}
    _ckeyTabCaches = {}
    _foreachCaches = {}
    _cellBinds = {}
    BindMetaWatchClear()
end

--- 删除监听
function BindMetaRemoveWatchs(t)
    if t == null then return end
    if type(t) ~= "table" then
        --- 删除单个watch
        _watchCache[t] = nil
        DataBinding:removeObserver(t)
        return
    end
    for _, id in pairs(t) do
        _watchCache[id] = nil
        DataBinding:removeObserver(id)
    end
end

--- 删除foreach的keypath缓存目录
function BindMetaPopForach()
    if not __open_use_set_cache__ then  return end

    local t = bindMeta_pop(_foreachCaches)
    if t then
        local _t
        for k, _ in pairs(t) do
            _t = _kpathCache[k]
            if _t then
                _kpathCache[k] = nil
                _t = getmetatable(_t)
                if _ckeyTabCaches[_t.__ck] then
                    _ckeyTabCaches[_t.__ck][_t] = nil
                end
            end
        end
    end
end
----------------------------------------------------------------------------------------------------------
----------------------------         建立 list cell 绑定属性                     --------------------------
---------------------------------------------------------------------------------------------------------
local function _getNextSplitType(v, index)
    if string.len(v) < index then
        return 0, 0
    end
    if string.byte(v, index) == 46 then -- .
        return string.byte(v, index + 1) - 48, index
    end
    return _getNextSplitType(v, index +1)
end
local function _getNextSplitIndex(v, index)
    if string.len(v) <= index then
        return index
    end
    if string.byte(v, index) == 46 then -- .
        return index
    end
    return _getNextSplitIndex(v, index +1)
end

-- 设置 list cell 绑定数据
-- https://git.wemomo.com/sun_109/LuaParser_JavaCode/-/issues/340
function BindMetaWatchListCell(source, section, row)
    if __open_combine_data__ and __open_use_set_cache__ then
        BindMetaPopForach()
    end
    local paths = bindMeta_pop(_cellBinds)
    if not paths then return end

    local s_path = bindMeta_path(getmetatable(source).__kvoname);

    if __open_use_argo_bind__ and __open_use_argo_bind__ == true then
        DataBinding:bindCell(s_path, section, row, paths)
        return
    end

    local ret, map = {}, {}
    local s_len = string.len(s_path)
    if section == -1 then -- 适配viewpager
        section = 1
    end
    local c1, c2, c2i, s_index, vl = 0, 0, 0, 0, 0
    local key = ""
    for _, v in ipairs(paths) do
        s_index = s_len
        vl = string.len(v)
        if vl >= s_index and string.sub(v,1, s_index) == s_path then
            if vl > (s_index + 3) then
                c1 = string.byte(v, s_index + 2) - 48
                c2, c2i = _getNextSplitType(v, s_index + 3)
                if section > 0 and c1 >= 0 and c1 <= 9 and c2 >= 0 and c2 <= 9 then
                    s_index = c2i
                end
                key = string.sub(v, _getNextSplitIndex(v,s_index + 2) + 1 )
            else
                key = nil
            end
        else
            key = v
        end
        if key and #key > 0 and map[key] ~= true then --去重
            ret[#ret + 1] = key
            map[key] = true
        end
    end
    DataBinding:bindCell(s_path,section,row, ret)
end
-------------------------------------------------------------------------------------------------------
--------------------------                   栈操作                           --------------------------
-------------------------------------------------------------------------------------------------------
bindMeta_push = function(t)
    if t then
        t[#t + 1] = {}
    end
end

bindMeta_pop = function (t)
    if t and #t > 0 then
        local v = t[#t]
        t[#t] = nil
        return v
    end
    return nil
end

bindMeta_get = function (t)
    if t and #t > 0 then
        return t[#t]
    end
    return nil
end

bindMeta_add = function (t, v, current)
    if current then
        local _t = bindMeta_get(t)
        if _t then
            _t[#_t + 1] = v
        end
    else
        for _, _v in ipairs(t) do
            _v[#_v + 1] = v
        end
    end
end
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

function BindMetaCreateFindGID(IDs) -- 创建全局表_G查找view变量名方法
    local gmt = getmetatable(_G)
    if gmt ~= nil then
        local __indexret = gmt.__index
        gmt.__index = function(t,k)
            if IDs[k] then return IDs[k] end -- 使用比较少 所以没必要变量保存
            if __indexret ~= nil then
                if type(__indexret) == "table" then
                    return __indexret[k]
                end
                return __indexret(t, k)
            end
            return nil
        end
    else
        setmetatable(_G, {__index = function(_,k) return IDs[k] end})
    end
end

-------------------------------------------------------------------------------------------------------
--------------------------        map/list初始化                        --------------------------
-------------------------------------------------------------------------------------------------------
function map()
    return setmetatable({}, {collectionType=1})
end
function array()
    return setmetatable({}, {collectionType=2})
end

-------------------------------------------------------------------------------------------------------
--------------------------      DEBUG / 在preview中使用                      --------------------------
-------------------------------------------------------------------------------------------------------
function BindMetaPreviewStart()
    debug_preview_open = true
    debug_preview_watch = true
end

function BindMetaPreviewEnd()
    debug_preview_open = false
    _kpathCache = {}
    _ckeyTabCaches = {}
end
-------------------------------------------------------------------------------------------------------
------------------------------     watch 链   -----------------------------------------------------
-------------------------------------------------------------------------------------------------------
---
--- 删除module
function removeModuleWatchs(module)
    if module and module.dealloc then
        module:dealloc()
    end
end


---
--- merge table
function BindMetaMerge(...)
    local size = select("#", ...)
    local ret = {}
    local index = 1
    for i = 1, size do
        local v = select(i, ...)
        if type(v) == "table" then
            for _, _v in ipairs(v) do
                ret[index] = _v
                index = index + 1
            end
        else
            ret[index] = v
            index = index + 1
        end
    end
    return ret
end

---//////////////////////////////////////////////////////////////////////////////
--- 子模块优化
---
--function clz:init(...)
--    return self
--end
--function clz:update(...)
--    self:dealloc()
--    self._isDealloc = false
--    self:updateData(...)
--    --for _, subModule in pairs(self.subs) do
--    --    --- 需修改参数
--    --    subModule:update(...)
--    --end
--    return self
--end
--function clz:updateData(...) ---重写
--    return self
--end
---//////////////////////////////////////////////////////////////////////////////

__module = {
    __innerPrivateFunc = {
        __initModuleClass = function()
            local clz = {
                dealloc = function(self)
                    if self._isDeallocating then return end
                    self._isDeallocating = true
                    if self._observerIndex > 1 then
                        BindMetaRemoveWatchs(self._observers)
                        self._observers = {}
                        self._observerIndex = 1
                    end
                    for _, subModule in pairs(self._subs) do
                        subModule:dealloc()
                    end
                    self._isDeallocating = false
                end,
                init = function(self, ...)
                    print("请实现 View 代码 ....")
                end,
                update = function(self, super, ...)
                    if super then self._autoWatch=super._autoWatch end
                    self.dealloc(self)
                    self.updateData(self, ...)
                end,
                updateData = function(self, ...)
                    print("请实现 module updateData ...")
                end,
                addObserverId = function(self, id)
                    if id then
                        self._observers[self._observerIndex] = id
                        self._observerIndex = self._observerIndex + 1
                    end
                    return id
                end
            }
            clz.__index = clz
            return clz
        end,
        __initSelf = function(super)
            local self = {
                _observers = {}, --- watchid集合
                _subs = {}, --- 子模块集合
                _subIndex = 1;
                _observerIndex = 1,
                _view = nil,
                _autoWatch = true,
                _isDeallocating = false,
            }
            local meta = {
                __index = function(t, k)
                    local ret = super[k]
                    if ret then return ret end

                    local view = rawget(t, "_view")
                    if view then
                        local method = view[k]
                        if method then
                            return __module.__innerPrivateFunc.__callView(view, method)
                        end
                    end
                    return nil
                end
            }
            --- 自动释放管理
            if newproxy then
                local prox = newproxy(true)
                getmetatable(prox).__gc = function()
                    super.dealloc(self)
                end
                meta.__prox = prox
            else
                meta.__gc = function()
                    super.dealloc(self)
                end
            end
            return setmetatable(self, meta)
        end,

        --- 消息转发调用view
        __callView = function(view, method)
            if type(method) ~= "function" then return method end
            local ret = __module.__innerPrivateFunc.__viewStack
            if ret == nil then
                ret = {calls = {}}
                ret.push = function(v, func)
                    ret.calls[#ret.calls + 1] = { v, func }
                end
                ret.pop = function()
                    local size = #ret.calls
                    if size > 0 then
                        local viewT = ret.calls[size]
                        ret.calls[size] = nil
                        return viewT
                    end
                    return nil
                end
                setmetatable(ret, {
                    __call = function(_, _, ...)
                        local t = ret.pop()
                        if t ~= nil then
                            return t[2](t[1], ...)
                        end
                        return nil
                    end
                })
                __module.__innerPrivateFunc.__viewStack = ret
            end
            ret.push(view, method)
            return ret
        end
    },

    defModule = function(moduleName)
        local class = __module.__innerPrivateFunc.__initModuleClass()
        _G[moduleName] = function(...)
            local self = __module.__innerPrivateFunc.__initSelf(class)
            self:init(...)
            return self
        end
        return class
    end
    ,
    Object = function()
       return __module.__innerPrivateFunc.__initSelf(__module.__innerPrivateFunc.__initModuleClass())
    end
    ,
    addSubModule = function(self, subModule, key)
        if self ~= nil and subModule ~= nil and type(self) == 'table' and self._subs ~= nil then
            if key then
                self._subs[key] = subModule
            else
                self._subs[self._subIndex] = subModule
                self._subIndex = self._subIndex + 1
            end
        end
    end
    ,
    weakSelf = function(self) --- self弱引用
        if __module.__empty == nil then
            __module.__empty = {}
            setmetatable(__module.__empty, {
                __newindex = function() end,
                __index = function() return __module.__empty end,
                __call = function() return __module.__empty end
            })
        end
        local __weak = setmetatable({self=self}, {__mode = 'v'})
        return setmetatable({}, {
            __index = function(_, k)
                if __weak.self == nil then
                    print("self has deallocated ... ")
                    return __module.__empty
                end
                return __weak.self[k]
            end,
            __newindex = function(_, k, v)
                if __weak.self == nil then
                    print("self has deallocated ... ")
                    return
                end
                __weak.self[k] = v
            end
        })
    end
    --- self指当前模块，不再指当前控件等 @see:https://git.wemomo.com/sun_109/LuaParser_JavaCode/-/issues/654
    --,
    --viewSelf = function(self, view) --- 自动区分self 是view还是module
    --    if self == nil or view == nil then return view end
    --    local __weak = setmetatable({self=self, view=view}, {__mode = 'v'})
    --    return setmetatable({}, {
    --        __index = function(_, k)
    --            if __weak.self == nil or __weak.view == nil then
    --                print("self has deallocated ... ")
    --                return __module.__empty
    --            end
    --            local ret = __weak.view[k]
    --            if ret ~= nil then
    --                return __module.__innerPrivateFunc.__callView(__weak.view, ret)
    --            end
    --            return __weak.self[k]
    --        end,
    --        __newindex = function(_, k, v)
    --            if __weak.self == nil or __weak.view == nil then
    --                print("self has deallocated ... ")
    --                return
    --            end
    --            __weak.self[k] = v
    --        end
    --    })
    --end
    ,
    initCell = function(cell, moduleSelf, autoWatch)
        cell._isCell_ = true
        cell._autoWatch = autoWatch
        cell._subs = {}
        cell._observers = {} --- watchid集合
        cell._subIndex = 1
        cell._observerIndex = 1
        setmetatable(cell, __module.__innerPrivateFunc.__initModuleClass())
        __module.addSubModule(moduleSelf, cell)
    end,
    foreach = { --- foreach
        container = function(superView, key, createAgain)
            local o = superView._subs[key]
            if o then o:dealloc() end
            if not createAgain and o then
                return o
            end
            o = {
                dealloc = function(self)
                    for _, v in pairs(self) do
                        if type(v) == "table" and v.dealloc then
                            v:dealloc()
                        end
                    end
                end}
            superView._subs[key] = o
            return o
        end,
        itemAutoInit = function(superView, container, index, createAgain)
            local ret = container[index]
            if ret then ret:dealloc() end
            if createAgain or ret == nil then
                ret = __module.Object()
                ret._initView = false;
            end
            ret._autoWatch = superView._autoWatch
            container[index] = ret
            local self = setmetatable({}, {
                __index = function(_, k)
                    local method = ret[k]
                    if method ~= nil then return __module.__innerPrivateFunc.__callView(ret, method) end
                    return __module.__innerPrivateFunc.__callView(superView, superView[k])
                end,
                __newindex = ret
            })
            return ret, self
        end,
    }
}
