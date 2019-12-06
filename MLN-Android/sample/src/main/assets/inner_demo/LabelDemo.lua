

local stateBar = window:stateBarHeight()  --状态栏高度
local label_1 = Label()
local str = StyleString('aaa')
label_1:width(50):height(50):marginTop(stateBar)
label_1:bgColor(Color(0,0,255,1))
label_1:cornerRadius(8):clipToBounds(true)  --圆角
str:underline(1)  --下划线
str:fontColor(Color(0,0,0,1))
label_1:styleText(str)
label_1:textColor(Color(255,255,255,1))
label_1:textAlign(TextAlign.CENTER)  --居中显示
window:addView(label_1)


local Label_2 = Label()
Label_2:text('bbb')
Label_2:x(120):y(stateBar)
Label_2:width(50):height(20)
Label_2:lines(0)  --0表示无限行
Label_2:bgColor(Color(255,0,0,0.1))
print(Label_2:height())
print(Label_2:width())
window:addView(Label_2)


local label = Label()
label:width(100):height(50):y(300)
label:text("alert"):fontSize(16):textAlign(TextAlign.CENTER)
label:addCornerMask(10, Color(255,255,255,1))
label:onClick(function ()
    Alert():title("title"):message("msg"):setOk("", function ()
        print("ok")
    end):setCancel("", function ()
        print("cancel")
    end):show()
    print(screen_h)
    print(window:height())
end)
label:bgColor(Color(125,125,125,1))
window:addView(label)


local label_3 = Label()
label_3:width(100):height(50):y(360)
label_3:text("list"):fontSize(16):textAlign(TextAlign.CENTER)
label_3:bgColor(Color(125,125,125,1))
label_3:onClick(function ()
    Alert():title("list title"):message("list msg"):setButtonList(Array():add("a1"):add("a2"):add("a3"),
            function (n)
                print("click", n)
            end):show()
end)
window:addView(label_3)


local label_4 = Label()
label_4:width(300):height(50):y(420)
label_4:styleText(StyleString("style"):append(StyleString("ic_launcher"):append(StyleString(" call nil"))))
label_4:fontSize(16):textAlign(TextAlign.CENTER)
label_4:bgColor(Color(125,125,125,1))
label_4:onClick(function ()
    Toast("after nil call", 1)
end)
window:addView(label_4)


local label_5 = Label()
label_5:width(100):height(50):y(480)
label_5:text("anim"):fontSize(16):textAlign(TextAlign.CENTER)
label_5:openRipple(true)  --高亮
label_5:bgColor(Color():hex(0xffff00):alpha(1))
label_5:onClick(function ()
    Animation()
    :setTranslateX(0, 100)
    :setTranslateY(0, 100)
    :setRotate(0, 180)
    :setScaleX(1, 1.5)
    :setScaleY(1, 1.5)
    :setAlpha(1, 0)
    :setDuration(1)
    :setDelay(0.5)
    :setAutoBack(true)
    :setInterpolator(InterpolatorType.Linear)
    :start(label_5)
end)
window:addView(label_5)


local label_6 = Label()
label_6:width(150):height(50):x(200):y(540)
label_6:text("GradientColor"):fontSize(16):textAlign(TextAlign.CENTER)
label_6:cornerRadius(10)
label_6:setGradientColor(Color(255,0,0,1), Color(0,0,255,1), true)
window:addView(label_6)


local label_7 = Label()
local str7 = StyleString("哈哈哈")
label_7:width(100):height(100):centerX(100):centerY(590)
str7:fontStyle(FontStyle.BOLD):fontColor(Color(255,0,0,1))
label_7:textAlign(TextAlign.LEFT)
label_7:styleText(str7)
label_7:bgColor(Color():hex(0xffe00e):alpha(0.5)):lines(1)
label_7:onClick(function ()
    if label_7:cornerRadius() > 0 then
        label_7:cornerRadius(0)
    else
        label_7:cornerRadius(20)
    end
end)
window:addView(label_7)

