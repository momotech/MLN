local linear = LinearLayout(LinearType.VERTICAL)
        :width(MeasurementType.MATCH_PARENT)
        :height(MeasurementType.MATCH_PARENT)

if System:iOS() then
    linear:marginTop(70)
else
    linear:marginTop(0)
end

window:addView(linear)


-- 输入文本自定义设置
local textSet = EditTextView()
        :width(300)
        :height(80)
        :marginTop(10)
        :marginLeft(10)
        :bgColor(Color(0,0,0,0.3))
        :placeholder("点击输入文本试试看")
        :padding(10,10,10,10)
        :textColor(Color(0,255,0,1))
        :textAlign(TextAlign.LEFT)
        :fontSize(20)
linear:addView(textSet)

-- 设置密码输入模式
local edit_password = EditTextView()
        :width(300)
        :height(MeasurementType.WRAP_CONTENT)
        :marginLeft(10)
        :marginTop(10)
        :bgColor(Color(0,0,0,0.3))
        :fontSize(18)
        :singleLine(true) --- 单行时密码模式才生效
        :passwordMode(true)
        :maxLength(6)
        :placeholder("密码模式，最多只能输入6个字符")
linear:addView(edit_password)

-- 键盘弹出收起
local edit_board = LinearLayout(LinearType.HORIZONTAL)
        :width(MeasurementType.MATCH_PARENT)
        :height(MeasurementType.WRAP_CONTENT)
        :marginTop(10)
linear:addView(edit_board)
-- 弹出键盘按钮
local show = Label()
        :width(MeasurementType.WRAP_CONTENT)
        :height(50)
        :bgColor(Color(0,0,0,0.3))
        :marginLeft(10)
        :text("弹出键盘")
        :fontSize(18)
edit_board:addView(show)
-- 收起键盘按钮
local hide = Label()
        :width(MeasurementType.WRAP_CONTENT)
        :height(50)
        :bgColor(Color(0,0,0,0.3))
        :marginLeft(10)
        :text("收起键盘")
        :fontSize(18)
edit_board:addView(hide)

show:onClick(function ()
    textSet:showKeyboard()
end)

hide:onClick(function ()
    textSet:dismissKeyboard()
end)

-- 设置光标颜色
local labelCursor0 = Label()
        :width(MeasurementType.WRAP_CONTENT)
        :height(MeasurementType.WRAP_CONTENT)
        :bgColor(Color(0,0,0,0.3))
        :marginTop(10):marginLeft(10)
        :fontSize(18)
        :text("设置光标颜色为蓝色")
linear:addView(labelCursor0)
labelCursor0:onClick(function ()
    textSet:setCursorColor(Color(0,0,255,1))
end)

local labelCursor1 = Label()
        :width(MeasurementType.WRAP_CONTENT)
        :height(MeasurementType.WRAP_CONTENT)
        :bgColor(Color(0,0,0,0.3))
        :marginTop(10):marginLeft(10)
        :fontSize(18)
        :text("设置光标颜色为红色")
linear:addView(labelCursor1)
labelCursor1:onClick(function ()
    textSet:setCursorColor(Color(255,0,0,1))
end)

local labelCursor2 = Label()
        :width(MeasurementType.WRAP_CONTENT)
        :height(MeasurementType.WRAP_CONTENT)
        :bgColor(Color(0,0,0,0.3))
        :marginTop(10):marginLeft(10)
        :fontSize(18)
        :text("设置光标颜色为黑色")
linear:addView(labelCursor2)
labelCursor2:onClick(function ()
    textSet:setCursorColor(Color(0,0,0,1))
end)

-- 设置文本是否可点击
canEdit = true
local labelCanEdit = Label()
        :width(MeasurementType.WRAP_CONTENT)
        :height(MeasurementType.WRAP_CONTENT)
        :bgColor(Color(0,0,0,0.3))
        :marginTop(10):marginLeft(10)
        :fontSize(18)
        :text("设置文本可点击")
linear:addView(labelCanEdit)
labelCanEdit:onClick(function ()
    textSet:setCanEdit(canEdit)
    if canEdit then
        labelCanEdit:text("设置文本不可点击")
        canEdit = false
    else
        labelCanEdit:text("设置文本可点击")
        canEdit = true
    end
end)

-- 测试callback回调
textSet:setBeginChangingCallback(function ()
    print("text begin change")
end)
textSet:setDidChangingCallback(function (now, start, count)
    print("now: ", now, " start: ", start, " count: ", count)
end)
textSet:setEndChangedCallback(function (s)
    print("the final text is : " , s)
end)