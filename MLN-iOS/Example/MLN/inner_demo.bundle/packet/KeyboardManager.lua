local _class = {}
_class._version = "1.0"
_class._classname = "KeyboardManager"

_class.WINDOW_PUSH = 1
_class.VIEW_PUSH = 2

_class.keyboardMode = _class.WINDOW_PUSH
_class.hasInit = false

_class.watchCallback = null --watch监听
_class.windowOffset = 0 --window上移后的补充位移。
_class.allEditTexts = {} --注册的所有输入框表，用于查询当前焦点的输入框
_class.bindEditViews = {} --绑定的输入框表，表示需要上移的输入框。未绑定的上移window
_class.bindNormalViews = {} --绑定的view表

_class.lastFocusEditTable = null --上一次焦点输入框
_class.lastRegisterEditTable = null --上一次焦点输入框
_class.lastTranslationY = 0 --window上一次上移的Y值。只在window上移时记录和使用

_class.keyboardListener = function(isShowing, keyboardHeight)
    local isWindowPush
    if _class.watchCallback then
        _class.watchCallback(isShowing, keyboardHeight)
    end

    ---- 键盘监听回调，处理流程
    --1. 遍历注册的allEditTexts，获取当前焦点的EditText。（所有editextView，都需要注册）
    --2. 查询当前editText，是否绑定在bindEditViews中。
    --
    -- 如果 isShowing = true
    --2.1 bindEditViews中有，且parent路径上没有绑定键盘，对绑定的editText，设置上移+偏移
    --2.2 bindEditViews中无，且parent路径上没有绑定键盘，对window设置上移+偏移
    -- 如果 isShowing = false
    --2.3 如果回调的焦点，和上一次的不同。使用上一次的焦点，执行2.1和2.2的逻辑
    --
    --3. 当2.1条件成立时，获取焦点EditText的_id，
    --3.1 缓存当前焦点的输入框
    --4. 遍历绑定的targetViews，
    --4.1 如果targetView 无"_id"，且parent路径上没有绑定键盘，设置上移+偏移。
    --4.2 如果targetView 有"_id"，且parent路径上没有绑定键盘，与当前焦点EditText的_id相同时，设置上移+偏移。
    --
    --备注逻辑：
    --绑定的view ，存在包裹关系，最外层绑定的parent生效
    --条件1: parent无id
    --条件2: 焦点无id，parent无id
    --条件3: 焦点有id，id 与 parent的id相同
    ---- end

    local registerEditTable --注册的当前焦点输入框table
    local focusBindEditTable --绑定的当前焦点输入框table
    --1. 遍历注册的allEditTexts，获取当前焦点的EditText。（所有editextView，都需要注册）
    for i = 1, #_class.allEditTexts do
        local temp = _class.allEditTexts[i] -- view = editTextView, offset = offset, _id = id
        if temp.view and temp.view:hasFocus() then
            registerEditTable = temp
            break --找到焦点了，跳出循环
        end
    end

    --2. 查询当前editText，是否绑定在bindEditViews中。
    for i = 1, #_class.bindEditViews do
        local tempEdit = _class.bindEditViews[i]
        if registerEditTable and tempEdit.view and registerEditTable.view == tempEdit.view then
            focusBindEditTable = tempEdit
            break
        end
    end

    if not isShowing then
        --收起时
        local registerChange = _class.lastRegisterEditTable and _class.lastRegisterEditTable ~= registerEditTable

        if registerChange then
            print("大人，时代变了")
            registerEditTable = _class.lastRegisterEditTable
            focusBindEditTable = _class.lastFocusEditTable
        end
    end

    local focusID = focusBindEditTable and focusBindEditTable._id or nil

    if focusBindEditTable and not _class:checkParentHasBinded(focusBindEditTable.view, focusID) then

        --2.1 bindEditViews中有，且parent路径上没有绑定键盘，对绑定的editText，设置上移+偏移
        _class:translateTarget(isShowing, keyboardHeight, focusBindEditTable, _class.VIEW_PUSH)
        --3. 2.1条件成立时，获取焦点EditText的_id
        focusID = focusBindEditTable._id


    elseif registerEditTable and not _class:checkParentHasBinded(registerEditTable.view, focusID) then
        --2.2 bindEditViews中无，且parent路径上没有绑定键盘，对window设置上移+偏移
        _class:translateTarget(isShowing, keyboardHeight, registerEditTable, _class.WINDOW_PUSH)
        _class.lastfocustable = registerEditTable
        isWindowPush = true
    end

    if isShowing then
        --3.1 缓存当前焦点的输入框
        _class.lastRegisterEditTable = registerEditTable
        _class.lastFocusEditTable = focusBindEditTable
    else
        _class.lastRegisterEditTable = nil
        _class.lastFocusEditTable = nil
    end

    if isWindowPush then
        return
    end

    --4. 遍历绑定的targetViews
    for i = #_class.bindNormalViews, 1, -1 do
        local tempViewTable = _class.bindNormalViews[i]

        if not tempViewTable._id and not _class:checkParentHasBinded(tempViewTable.view, focusID) then
            --4.1 如果targetView 无"_id"，且parent路径上没有绑定键盘，设置上移+偏移。
            _class:translateTarget(isShowing, keyboardHeight, tempViewTable, _class.VIEW_PUSH)
        else
            --4.2 如果targetView 有"_id"，且parent路径上没有绑定键盘，与当前焦点EditText的_id相同时，设置上移+偏移。
            if focusID == tempViewTable._id and not _class:checkParentHasBinded(tempViewTable.view, focusID) then
                _class:translateTarget(isShowing, keyboardHeight, tempViewTable, _class.VIEW_PUSH)
            end
        end
    end

end

function _class:cacheLastEditTable(registerEditTable, focusEditTable)
    _class.lastRegisterEditTable = registerEditTable
    _class.lastFocusEditTable = focusEditTable
end

----
--- 绑定位移的view，与绑定的容器嵌套，不做位移
function _class:checkParentHasBinded(targetView, focusID)
    local parent = targetView:superview()
    if parent then
        for i = 1, #_class.bindNormalViews do
            local viewtable = _class.bindNormalViews[i]
            if viewtable and viewtable.view == parent then
                if (not viewtable._id) or (not focusID and not viewtable._id) or focusID and focusID == viewtable._id then
                    --位移向上转移
                    --条件1: parent无id
                    --条件2: 焦点无id，parent无id
                    --条件3: 焦点有id，id 与 parent的id相同
                    print("包裹啦")
                    return true
                end
            end
        end

        if parent ~= window then
            return _class:checkParentHasBinded(parent, focusID)
        end
    end

    return false
end

----
---- 位移代码实现
function _class:translateTarget(isShowing, keyboardHeight, viewTable, keyboardMode)
    print("模式：" .. (keyboardMode == _class.WINDOW_PUSH and "window" or "view"))
    local lastTranslationY
    local offset
    local targetView = viewTable.view

    local parent = targetView:superview()
    if not parent or
            targetView == parent then
        print("目标view 未addView、或目标view错误")
        return
    end

    if isShowing then
        if keyboardMode == _class.WINDOW_PUSH then
            offset = _class.windowOffset or 0
        else
            offset = viewTable.offset or 0
        end

        local screen_h = window:height()
        --print("keyboardHeight: " .. tostring(screen_h - keyboardHeight) .. " ,isShowing: " .. tostring(isShowing) .. ", windowHeight: " .. tostring(window:height()))
        local targetPoint = targetView:convertPointTo(window, Point(0, targetView:height()))
        local needTranslate = screen_h - keyboardHeight < targetPoint:y()
        local offesetY = targetPoint:y() - screen_h + keyboardHeight
        lastTranslationY = needTranslate and -offesetY - offset or 0
        --print(offesetY)
    else
        if keyboardMode == _class.WINDOW_PUSH then
            lastTranslationY = -_class.lastTranslationY
        else
            lastTranslationY = -viewTable.lastTranslationY or 0
        end
    end

    if keyboardMode == _class.WINDOW_PUSH then
        window:translation(0, lastTranslationY, false)
        _class.lastTranslationY = lastTranslationY
    else
        targetView:translation(0, lastTranslationY, false)
        viewTable.lastTranslationY = lastTranslationY
    end
end

---- window 绑定键盘，对子View整体控制
function _class:keyboardOffset(offset)
    _class.windowOffset = offset
end

---- 绑定单个EditText，跟随键盘移动
---  @mode VIEW_PUSH：对view上移，WINDOW_PUSH：对window上移
---  @offset 上移以后，相对键盘的偏移量。可以不传，默认：0。
---  @id 相同id的组件，上移。可以不传，表示不绑定id。
function _class:bindEditText(mode, editTextView, offset, id)
    if mode == _class.VIEW_PUSH then
        table.insert(_class.allEditTexts, { view = editTextView, offset = 0 })
        table.insert(_class.bindEditViews, { view = editTextView, offset = offset, _id = id })
    else
        table.insert(_class.allEditTexts, { view = editTextView, offset = 0 })
    end
end

---- 绑定单个view，跟随键盘移动
---  @offset 上移以后，相对键盘的偏移量。可以不传，默认：0。
---  @id 相同id的组件，上移。可以不传，表示不绑定id。
function _class:bindView(view, offset, id)
    table.insert(_class.bindNormalViews, { view = view, offset = offset, _id = id })
end

function _class:watchKeyboard(fun)
    _class.watchCallback = fun
end

window:keyboardShowing(_class.keyboardListener)

return _class
