-- local tb = LinearLayout():width(MeasurementType.MATCH_PARENT)
-- tb:bgColor(Color(78, 127, 255))
-- window:addView(tb)
-- kScreenWidth =__System():screenSize():width()
-- Toast(kScreenWidth)
-- print(__View)
--package.preload["ClipChildren"] = function(module) print("module ", module) end
--package.searchers[1] = function(module) print("searchers 1 ", module) return function(module) print("my loader") end end
--package.searchers[2] = nil
--require("a.b")
--local a=CameraSetting():bitRate(10)
--Printer2:printObject("jjjjj")
--local a=Printer2:getA():bitRate()
--Toast(a.."jjj",1)
--print(window:height())
--window:addView(View():width(100):height(5000):bgColor(Color(0, 0, 0,1)))
--
--Loading2():show()
--Printer2:printObject("hello world")
--Printer2:printObject(FontStyle2.BOLD)

styleString1 = StyleString()
        :setText("为了更好的保障您的合法权益，请您阅读并同意以下协议")
        :fontSize(14)
        :fontColor(Color(193, 193, 193, 1))
styleString2 = StyleString()
        :setText("《用户协议》")
        :fontSize(14)
        :fontColor(Color(0,0,0,1))

        :fontColor(Color(0,0,0,1))


styleString4 = StyleString()
        :setText("《隐私政策》")
        :fontSize(14)
        :fontColor(Color(0,0,0,1))


styleString1
    :append(styleString2)
    :append(styleString4)

agreeLabel = Label()
        :width(MeasurementType.MATCH_PARENT)
        :height(MeasurementType.WRAP_CONTENT)
        :setGravity(Gravity.CENTER_HORIZONTAL)
        :fontSize(14)
        :marginLeft(35)
        :marginRight(35)
        :lines(4)
        :textAlign(TextAlign.CENTER)
        :marginTop(15)
        :styleText(styleString1)
phoneEdit = EditTextView():width(400):height(100)

window:addView(phoneEdit)
window:keyboardShowing(function(isShowing, keyboardHeight)

end)