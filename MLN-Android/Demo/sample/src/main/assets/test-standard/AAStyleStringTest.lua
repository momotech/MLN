---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by momo.
--- DateTime: 2019-04-10 14:51
---
scrollView = ScrollView()
        :marginTop(84)
        :width(MeasurementType.MATCH_PARENT)
        :height(window:height() - 84)

linear = LinearLayout(LinearType.VERTICAL)
window:addView(scrollView)
scrollView:addView(linear)

label0 = Label()
        :marginTop(10)
        :bgColor(Color(255, 0, 0, 0.5))
        :setGravity(Gravity.CENTER_HORIZONTAL)
styleT0 = StyleString("Oh看我样式ABC")
        :fontStyle(FontStyle.ITALIC)
        :setFontStyleForRange(FontStyle.BOLD, 1, 3)
label0:styleText(styleT0)
linear:addView(label0)

label1 = Label()
        :marginTop(10)
        :bgColor(Color(255, 0, 0, 0.5))
        :setGravity(Gravity.CENTER_HORIZONTAL)
styleT1 = StyleString("Oh看我字体ABC")
        :fontName("DIN_Condensed_Bold")
        :setFontNameForRange("STSongti-SC-Black", 1, 2)
label1:styleText(styleT1)
linear:addView(label1)

label2 = Label()
        :marginTop(10)
        :bgColor(Color(255, 0, 0, 0.5))
        :setGravity(Gravity.CENTER_HORIZONTAL)
styleT2 = StyleString("Oh看我颜色ABC")
        :fontColor(Color(255, 255, 255, 1))
        :setFontColorForRange(Color(255, 255, 0, 1), 4, 5)
label2:styleText(styleT2)
linear:addView(label2)

label3 = Label()
        :marginTop(10)
        :bgColor(Color(255, 0, 0, 0.5))
        :setGravity(Gravity.CENTER_HORIZONTAL)
--bug:单行超出文字ios无... android有
styleT3 = StyleString("Oh看我大小ABC!!!Oh看我大小ABC!!!Oh看我大小ABC!!!Oh看我大小ABC!!!Oh看我大小ABC!!!")
        :fontSize(10)
        :setFontSizeForRange(20, 1, 3)
label3:styleText(styleT3)
linear:addView(label3)

label4 = Label()
        :marginTop(10)
        :setGravity(Gravity.CENTER_HORIZONTAL)
styleT4 = StyleString("Oh看我背景ABC")
        :backgroundColor(Color(255, 0, 0, 0.5))
        :setBackgroundColorForRange(Color(255, 255, 0, 1), 1, 3)
label4:styleText(styleT4)
linear:addView(label4)

label5 = Label()
        :marginTop(10)
        :bgColor(Color(255, 0, 0, 0.5))
        :setGravity(Gravity.CENTER_HORIZONTAL)
styleT5 = StyleString("Oh看我下划线ABC")
--bug2：安卓先设下划线后不下划线失效
        :underline(UnderlineStyle.LINE)
        :setUnderlineForRange(UnderlineStyle.NONE, 1, 3)
label5:styleText(styleT5)
linear:addView(label5)

label6 = Label()
        :marginTop(10)
        :bgColor(Color(255, 0, 0, 0.5))
        :setGravity(Gravity.CENTER_HORIZONTAL)
styleT6 = StyleString("label1+label2:"):append(styleT1:append(styleT2))
label6:styleText(styleT6)
linear:addView(label6)

label7 = Label():marginTop(10)
                :setGravity(Gravity.CENTER_HORIZONTAL)



styleT7 = StyleString("http://img.momocdn.com/album/4F/CF/4FCFA0D2-95E8-3C09-3760-142E6916CA1B20170701_S.jpg")
        :backgroundColor(Color(255, 0, 255, 0.5))
styleT7:showAsImage(Size(100, 100))--文本内容应是图片地址,返回图片是否设置成功
label7:styleText(styleT7)
linear:addView(label7)

label8 = Label()
        :marginTop(10)
        :setGravity(Gravity.CENTER_HORIZONTAL)
size1 = styleT1:calculateSize(20)--返回size



styleT8 = StyleString("Oh我是混搭style,calculateSize(20):" .. size1:width() .. "," .. size1:height())
        :append(styleT7)
        :fontName("DIN_Condensed_Bold")
        :setFontNameForRange("STSongti-SC-Black", 6, 8)
        :fontColor(Color(255, 255, 255, 1))
        :setFontColorForRange(Color(255, 255, 0, 1), 4, 5)
        :fontSize(10)
        :setFontSizeForRange(20, 1, 3)
        :backgroundColor(Color(255, 0, 0, 0.5))
        :setBackgroundColorForRange(Color(255, 255, 0, 1), 1, 3)
        :underline(UnderlineStyle.LINE)
        :setUnderlineForRange(UnderlineStyle.NONE, 5, 7)
label8:styleText(styleT8)
linear:addView(label8)




label9 = Label():text("eyovnkdsajfsvncjkdnvskjnurfneu南方 i 而你看 v 说弄 iu 凤凰乌俄请回复牛额没法破饿哦")
linear:addView(label9)

LabelContent = Label():marginTop(10)
LabelContent:textColor(Color(255, 255, 0, 0.6))
--LabelContent:fontSize(10)
str = StyleString()
local mm = "玩家的名字:" .. "你好哈哈哈哈哈"
print(string.find(mm, ":"))
str:setText("玩家的名字:" .. "你好哈哈哈哈哈")
str:setFontColorForRange(Color(255, 0, 0), 0, 12)
LabelContent:styleText(str)
linear:addView(LabelContent)