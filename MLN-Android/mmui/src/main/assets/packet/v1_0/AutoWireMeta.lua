---
--- BindMeta.lua
--- Created by wangyang.
--- DateTime: 2020-11-06
--- 版本号 每次修改完内容后需要自动增加版本号/或者保证不会影响老版本
--- @version 1.0

-----------------------------------------------------------------------------------------------------------
---------------------- 获取数据要用此方法，防止元表方法引起的死循环              --------------------------
-----------------------------------------------------------------------------------------------------------

local hook_get = _G["rawget"]
local hook_set = _G["rawset"]

-----------------------------------------------------------------------------------------------------------
---------------------- 设置数据更改标记   __update                           --------------------------
-----------------------------------------------------------------------------------------------------------

local DATA_UPDATE = 1;
local DATA_DEFAULT = 0;

-- 初始化数据表的__update的各项为DATA_DEFAULT
local function initUpdate(o, flag)
    local __update = {}
    for k, v in pairs(o) do
        -- k为索引，v为索引对应的value
        hook_set(__update, k, flag)
    end
    return __update
end

-----------------------------------------------------------------------------------------------------------
---------------------- 原表操作  __index/__newindex/__len                   --------------------------
-----------------------------------------------------------------------------------------------------------

-- __index
--- @param tab table 元表
local function autoWire__index(tab)
    tab.__index = function(t, k)
        return tab.__o[k]
    end
end

-- __newindex
--- @param tab table 元表
local function autoWire__newindex(tab)
    tab.__newindex = function(t, k, v)
        -- 记录更改位置
        hook_set(tab.__update, k, DATA_UPDATE)
        local newV = AutoWirePack(v)
        hook_set(tab.__o, k, newV)
    end
end

--- @param tab table 元表
local function autoWire__len(tab)
    tab.__len = function(t)
        return #tab.__o
    end
end

-------------------------------------------------------------------------------------------------------------
------------------------------ hook table 所有方法                 --------------------------
-----------------------------------------------------------------------------------------------------------

if hook_t == nil then
    hook_t = {}
    for k, v in pairs(table) do
        hook_t[k] = v
    end
    for k, v in pairs(hook_t) do
        table[k] = function(t, ...)
            if hook_get(t, "isAutoWireHook") then
                local meta = getmetatable(t)

                -- 处理remove
                if k == "remove" then
                    local size = select("#", ...)
                    if size == 0 then
                        hook_set(meta.__update, #t, DATA_UPDATE)
                    else
                        local index = select(1, ...)
                        hook_set(meta.__update, index, DATA_UPDATE)
                    end
                end
                -- 处理insert
                if k == "insert" then
                    local size = select("#", ...)
                    if size == 1 then
                        local __v = select(1, ...)
                        hook_set(meta.__update, #t + 1, DATA_UPDATE)
                        local newV = AutoWirePack(__v)
                        return hook_t[k](meta.__o, newV)
                    else
                        local index = select(1, ...)
                        local __v = select(2, ...)
                        hook_set(meta.__update, index, DATA_UPDATE)
                        local newV = AutoWirePack(__v)
                        return hook_t[k](meta.__o, index, newV)
                    end
                end
                -- 处理sort
                if k == "sort" then
                    meta.__update = initUpdate(meta.__update, DATA_UPDATE)
                end

                return hook_t[k](meta.__o, ...)
            end
            -- 不需要中转，走以前逻辑
            return hook_t[k](t, ...)
        end
    end
end

-------------------------------------------------------------------------------------------------------------
------------------------------ hook global table 的相关方法                  --------------------------
-----------------------------------------------------------------------------------------------------------

if hook_g_t == nil then
    local global_table = {
        "ipairs",
        "pairs",
        "next",
        "rawget",
        "rawset",
    }
    hook_g_t = {}
    for k, v in pairs(global_table) do
        hook_g_t[k] = _G[v]
        _G[v] = function(t, ...)
            if hook_get(t, "isAutoWireHook") then
                local meta = getmetatable(t)
                if k == "rawset" then
                    local index = select(1, ...)
                    local __v = select(2, ...)
                    hook_set(meta.__update, index, DATA_UPDATE)
                    local newV = AutoWirePack(__v)
                    return hook_g_t[k](meta.__o, index, newV)
                end
                return hook_g_t[k](meta.__o, ...)
            end
            -- 不需要中转，走以前逻辑
            return hook_g_t[k](t, ...)
        end
    end
end

-------------------------------------------------------------------------------------------------------------
--------------------- 归并list的更改，如果Array中有一个item改变，标记整个list有改变 --------------------------
-----------------------------------------------------------------------------------------------------------
--- 判断array中是否有index发生改变
local function changeArray(o)
    local change = false
    local meta = getmetatable(o)
    local __update = meta.__update
    -- 查看array的元表，看看是否有数据改变
    for k, v in pairs(__update) do
        -- k为索引，v为索引对应的value
        if v == DATA_UPDATE then
            change = true
            return change
        end
    end
    return change
end

local function mergerArray(o)
    if type(o) == "table" then
        local meta = getmetatable(o)
        for k, v in pairs(o) do
            -- 处理table
            if type(v) == "table" then
                -- 处理本层未标记改变状态的array，但array自身有index改变的array
                if table.getn(v) > 0 and hook_get(meta.__update, k) ~= DATA_UPDATE and changeArray(v) == true then
                    hook_set(meta.__update, k, DATA_UPDATE)
                else
                    -- 处理map，即查找下层是否有array
                    mergerArray(v)
                end
            end
        end
    end
    return o
end

----------------------------------------------------------------------------------------------------------------
-------------------------------- 主入口方法  初始化                 --------------------------
-------------------------------------------------------------------------------------------------------------
--- @param o table 初始化对象
--- 对table进行装包
function AutoWirePack(o)
    -- 已经包装过的，不需要再包装
    if o == nil or type(o) ~= "table" or hook_get(o, "isAutoWireHook") == true then
        return o;
    end
    local newO = { isAutoWireHook = true }
    local meta = getmetatable(o)
    local mt = {
        __mt = meta,
        __o = o, -- 原数据的table
        __update = initUpdate(o, DATA_DEFAULT), -- 真正改变的值放到一个table中
    }
    autoWire__index(mt)
    autoWire__newindex(mt)
    autoWire__len(mt)
    setmetatable(newO, mt)
    for k, v in pairs(o) do
        -- k为索引，v为索引对应的value
        local newV = AutoWirePack(v)
        o[k] = newV -- 重新赋值
    end
    return newO;
end

--- 对table进行拆包
local function realAutoWireUnPack(o)
    -- 未包装过的，不需要拆包
    if o == nil or type(o) ~= "table" or getmetatable(o) == nil or hook_get(o, "isAutoWireHook") == nil then
        return o;
    end
    local mt = getmetatable(o)
    local newO = mt.__o
    local meta = mt.__mt
    if meta == nil then
        meta = map()
    end
    meta.__update = mt.__update
    setmetatable(newO, meta)
    for k, v in pairs(newO) do
        -- k为索引，v为索引对应的value
        local newV = AutoWireUnPack(v)
        newO[k] = newV -- 重新赋值
    end
    return newO;
end

function AutoWireUnPack(o)
    local table = realAutoWireUnPack(o)
    return mergerArray(table)
end

