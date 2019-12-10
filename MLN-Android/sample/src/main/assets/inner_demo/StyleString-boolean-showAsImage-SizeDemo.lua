

local screen_w = window:size():width()

startString = StyleString()
startString:setText("这个一个开头这个一个开头这个一个开头这个一个开头这个一个开头")
startString:fontColor(Color(12,123,255,1.0))

imageString = StyleString()
imageString:setText("http://img1.3lian.com/img013/v5/21/d/84.jpg")
imageString:showAsImage(Size(100, 100))

endString = StyleString()
endString:setText("这是结束这是结束这是结束这是结束这是结束这是结束这是结束")
endString:fontColor(Color(33, 33, 33, 0.5))
endString:fontSize(18)

wholeString = StyleString()
wholeString:append(startString):append(endString)

label = Label():marginLeft(0):marginTop(80):width(screen_w):height(200):lines(0)
label:styleText(wholeString)
window:addView(label)

insertImageLabel = Label()
insertImageLabel:text("插入图片"):textAlign(TextAlign.CENTER):width(100):height(40):setGravity(Gravity.CENTER_HORIZONTAL):marginTop(400)
insertImageLabel:textColor(Color(123, 123, 123, 1))
insertImageLabel:onClick(function ()
    newWholeString = StyleString()
    newWholeString:append(startString):append(imageString):append(endString)
    label:styleText(nil)
    label:styleText(newWholeString)
end)
window:addView(insertImageLabel)

