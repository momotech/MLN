
label = Label():marginTop(120):marginLeft(50):bgColor(Color(122,21,22,1.0))
label:text("我是中国人")
window:addView(label)


-- 此时label的宽度为0
print("width:",label:width())

-- 此时我想获取label的宽度，就可以调用requestLayout方法
window:requestLayout()

print("width:",label:width())



