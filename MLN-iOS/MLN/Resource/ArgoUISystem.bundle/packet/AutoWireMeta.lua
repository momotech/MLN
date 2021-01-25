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
local hook_table_insert = table["insert"]

-----------------------------------------------------------------------------------------------------------
---------------------- 设置数据更改标记   __update（记录用户的操作流程）        --------------------------
-----------------------------------------------------------------------------------------------------------

local DATA_UPDATE = 1;
local DATA_INSERT = 2;
local DATA_REMOVE = 3;
local DATA_SORT = 4;

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
        hook_table_insert(tab.__update, { op = DATA_UPDATE, key = k, value = AutoWireUnPack(v) })
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
                        hook_table_insert(meta.__update, { op = DATA_REMOVE, key = #t})
                    else
                        local index = select(1, ...)
                        hook_table_insert(meta.__update, { op = DATA_REMOVE, key = index })
                    end
                end
                -- 处理insert
                if k == "insert" then
                    local size = select("#", ...)
                    if size == 1 then
                        local __v = select(1, ...)
                        hook_table_insert(meta.__update, { op = DATA_INSERT, key = #t + 1, value = AutoWireUnPack(__v)})
                        local newV = AutoWirePack(__v)
                        return hook_t[k](meta.__o, newV)
                    else
                        local index = select(1, ...)
                        local __v = select(2, ...)
                        hook_table_insert(meta.__update, { op = DATA_INSERT, key = index, value = AutoWireUnPack(__v)})
                        local newV = AutoWirePack(__v)
                        return hook_t[k](meta.__o, index, newV)
                    end
                end
                -- 处理sort
                if k == "sort" then
                    hook_table_insert(meta.__update, { op = DATA_SORT })
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
                    hook_table_insert(meta.__update, { op = DATA_UPDATE, key = index, value = AutoWireUnPack(__v) })
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
        __update = array(), -- 真正改变的值放到一个table中
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
function AutoWireUnPack(o)
    -- 未包装过的，不需要拆包
    if o == nil or type(o) ~= "table" or hook_get(o, "isAutoWireHook") == nil or getmetatable(o) == nil then
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

