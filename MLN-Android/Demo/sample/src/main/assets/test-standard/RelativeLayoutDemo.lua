relative = RelativeLayout()


relative:width(300)
relative:height(300)
relative:bgColor(Color(30, 130, 20, 1))





label = Label()
label:width(100)
label:height(50)
label:text("   source view ")
-- relative:alignParentTop(label)





label2 = Label()
label2:width(100)
label2:height(50)
label2:marginTop(20)
label2:text("   relative view ")

--relative:alignParentBottom(label2)
-- relative:alignParentRight(label2)
--relative:right(label,label2)
relative:bottom(label,label2)

--relative:left(label,label2)
-- relative:top(label,label2)



window:addView(relative)

