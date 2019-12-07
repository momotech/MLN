
local size = window:size()
local stateBar = window:stateBarHeight()
screen_w = size:width()
screen_h = size:height()

--示例：单行数字模式
local textField = EditTextView():textColor(Color(0, 0, 255, 1))
textField:frame(Rect(10, 10 + stateBar, 200, 50))
textField:fontSize(23)
textField:padding(6, 0, 0, 0)
textField:inputMode(EditTextViewInputMode.Number)
textField:placeholder("数字|光标|编辑")  --内容为空时显示的提示文字
textField:setCursorColor(Color(255, 0, 0, 1))
textField:setEndChangedCallback(function()
    print("textView1:", textField:text())
end)
window:addView(textField)

-- 示例：多行模式，最大字符限制
local textField2 = EditTextView():textColor(Color(255, 255, 255, 1))
textField2:width(200):height(60):marginLeft(10):marginTop(100)
textField2:bgColor(Color(223, 123, 0, 1))
textField2:fontSize(18)
textField2:placeholder("默认多行\n最大字数:10")
textField2:maxLength(10)
textField2:padding(6, 0, 0, 0)
textField2:setEndChangedCallback(function()
    print(textField2:text())
end)
window:addView(textField2)

-- 示例：单行模式密码
local textField3 = EditTextView():textColor(Color(255, 255, 255, 1))
textField3:bgColor(Color(223, 123, 0, 1))
textField3:frame(Rect(10, 200, 200, 70))
textField3:fontSize(18)
textField3:singleLine(true)
textField3:placeholder("单行模式密码\n \\n还能换行")
textField3:passwordMode(true)
textField3:setEndChangedCallback(function()
    print("textView:", textField3:text())
end)
window:addView(textField3)


-- 示例：单行模式正常
local textField4 = EditTextView():textColor(Color(255, 255, 255, 1))
textField4:bgColor(Color(223, 123, 0, 1))
textField4:frame(Rect(10, 350, 233, 50))
textField4:fontSize(18)
textField4:singleLine(true)
textField4:maxBytes(10)
textField4:placeholder("单行模式正常，MaxBytes:10")
textField4:setEndChangedCallback(function(s)  --设置内容修改完毕的回调
    print("EndChange:", s)
end)
textField4:setDidChangingCallback(function(text, start, count)  --设置文字已经修改的回调
    print("DidChang: ", text, " start: " .. start, " count: " .. count)
end)
window:addView(textField4)

-- 示例：隐藏键盘
local dismissKeyboardView = Label():textColor(Color(255, 255, 255, 1)):textAlign(TextAlign.CENTER)
dismissKeyboardView:text("隐藏键盘")
dismissKeyboardView:width(80):height(50):marginLeft(screen_w - 120):marginTop(stateBar + 5)
dismissKeyboardView:bgColor(Color(55, 55, 55, 1))
dismissKeyboardView:onClick(function()
    textField2:dismissKeyboard()
end)
window:addView(dismissKeyboardView)

-- 示例：MaxLength +1
local addMaxLengthBtn = Label():textColor(Color(255, 255, 255, 1)):textAlign(TextAlign.CENTER):fontSize(15)
addMaxLengthBtn:text("MaxLength +1")
addMaxLengthBtn:width(MeasurementType.WRAP_CONTENT):height(50):marginLeft(screen_w - 120):marginTop(80):padding(0, 5, 0, 5)
addMaxLengthBtn:bgColor(Color(55, 55, 55, 1))
addMaxLengthBtn:onClick(function()
    textField2:maxLength(textField2:maxLength()+1)
    print("textField2:maxLength(): ", textField2:maxLength())
end)
window:addView(addMaxLengthBtn)

-- 示例：MaxBytes +1
local addMaxBytesBtn = Label():textColor(Color(255, 255, 255, 1)):textAlign(TextAlign.CENTER):fontSize(15)
addMaxBytesBtn:text("MaxBytes +1")
addMaxBytesBtn:width(MeasurementType.WRAP_CONTENT):height(50):marginLeft(screen_w - 120):marginTop(140):padding(0, 5, 0, 5)
addMaxBytesBtn:bgColor(Color(55, 55, 55, 1))
addMaxBytesBtn:onClick(function()
    textField4:maxBytes(textField4:maxBytes() + 1)
    print("textField4:maxBytes(): ", textField4:maxBytes())
end)
window:addView(addMaxBytesBtn)

-- 示例：MaxBytes -1
local addMaxBytesBtn = Label():textColor(Color(255, 255, 255, 1)):textAlign(TextAlign.CENTER):fontSize(15)
addMaxBytesBtn:text("MaxBytes -1")
addMaxBytesBtn:width(MeasurementType.WRAP_CONTENT):height(50):marginLeft(screen_w - 120):marginTop(210):padding(0, 5, 0, 5)
addMaxBytesBtn:bgColor(Color(55, 55, 55, 1))
addMaxBytesBtn:onClick(function()
    textField4:maxBytes(textField4:maxBytes() - 1)
    print("textField4:maxBytes(): ", textField4:maxBytes())
end)
window:addView(addMaxBytesBtn)

-- 示例：设置光标颜色
local changeTag = 1
local addMaxBytesBtn = Label():textColor(Color(255, 255, 255, 1)):textAlign(TextAlign.CENTER):fontSize(15)
addMaxBytesBtn:text("光标颜色：红/绿")
addMaxBytesBtn:width(MeasurementType.WRAP_CONTENT):height(50):marginLeft(screen_w - 125):marginTop(280):padding(0, 5, 0, 5)
addMaxBytesBtn:bgColor(Color(55, 55, 55, 1))
addMaxBytesBtn:onClick(function()
    if changeTag == 1 then
        textField:setCursorColor(Color(255, 0, 0, 1))
        changeTag = 2
    else
        textField:setCursorColor(Color(0, 255, 0, 1))
        changeTag = 1
    end

end)
window:addView(addMaxBytesBtn)

-- 示例：enable
local changeTag = true
local addMaxBytesBtn = Label():textColor(Color(255, 255, 255, 1)):textAlign(TextAlign.CENTER):fontSize(15)
addMaxBytesBtn:text("编辑开关："..tostring(changeTag))
addMaxBytesBtn:width(MeasurementType.WRAP_CONTENT):height(50):marginLeft(screen_w - 120):marginTop(350):padding(0, 5, 0, 5)
addMaxBytesBtn:bgColor(Color(55, 55, 55, 1))
addMaxBytesBtn:onClick(function()
    if changeTag  then
        changeTag = false
        addMaxBytesBtn:text("编辑开关: "..tostring(changeTag))
        textField:setCanEdit(changeTag)  --设置文本是否可编辑
        textField2:setCanEdit(changeTag)
        textField3:setCanEdit(changeTag)
        textField4:setCanEdit(changeTag)
    else
        changeTag = true
        addMaxBytesBtn:text("编辑开关: "..tostring(changeTag))
        textField:setCanEdit(changeTag)
        textField2:setCanEdit(changeTag)
        textField3:setCanEdit(changeTag)
        textField4:setCanEdit(changeTag)
    end

end)
window:addView(addMaxBytesBtn)

