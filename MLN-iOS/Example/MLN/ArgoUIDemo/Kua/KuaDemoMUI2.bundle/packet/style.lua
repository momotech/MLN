_view_style_param_func_ = {
    -- 1
    function(view, func, value)
        func(view, value[1])
    end,
    -- 2
    function(view, func, value)
        func(view, value[1], value[2])
    end,
    -- 3
    function(view, func, value)
        func(view, value[1], value[2], value[3])
    end,
    -- 4
    function(view, func, value)
        func(view, value[1], value[2], value[3], value[4])
    end,
    -- 5
    function(view, func, value)
        func(view, value[1], value[2], value[3], value[4], value[5])
    end
}

function _view_set_style(view, style)
    if not style then return end
    for _k, _v in pairs(style) do
        if type(_k) == "number" then
            if type(_v) == "table" then
                _view_set_style(view, _v)
            end
        else
            local _a_k_f = view[_k]
            if _a_k_f then
                if type(_v) == "table" then
                    local _v_length = #_v
                    _view_style_param_func_[_v_length](view, _a_k_f, _v)
                else
                    _a_k_f(view, _v)
                end
            else
                if type(_v) == "function" then
                    _v(view)
                end
            end
        end
    end
end
function _view_set_style_with_filter(view, style, filter)
    if not style then return end
    for _k, _v in pairs(style) do
        if type(_k) == "number" then
            if type(_v) == "table" then
                _view_set_style_with_filter(view, _v, filter)
            end
        else
            if not filter[_k] then
                local _a_k_f = view[_k]
                if _a_k_f then
                    if type(_v) == "table" then
                        local _v_length = #_v
                        _view_style_param_func_[_v_length](view, _a_k_f, _v)
                    else
                        _a_k_f(view, _v)
                    end
                else
                    if type(_v) == "function" then
                        _v(view)
                    end
                end
            end
        end
    end
end