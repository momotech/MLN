
label =  Label():marginTop(120):height(30):bgColor(Color(121,12,45,1.0)):setGravity(Gravity.CENTER_HORIZONTAL)
label:text("点我弹个Toast")

window:addView(label)

Toast('你好啊david',1.0)

label:onClick(function()
    Toast("点击了Label",2.0)
end)
