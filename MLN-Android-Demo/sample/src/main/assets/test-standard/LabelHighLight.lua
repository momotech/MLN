label = Label():marginTop(100):width(200):height(30)
label:text("我是一个大傻逼哈哈哈，你信不！")

window:addView(label)

texts = Array()
texts:add("大傻逼")
texts:add("你信不")

label:addTapTexts(texts,function(text,index)
    print("text",text,index)
end,Color(211,11,211,1.0))