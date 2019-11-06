userView = LinearLayout(LinearType.VERTICAL)

userView:bgColor(Color(255, 255, 255, 1))
        :padding(10, 10, 10, 10)
        :setGravity(Gravity.RIGHT)
        :marginTop(100)

--昵称
nameLabel = Label()
nameLabel:text("昵称"):fontSize(16):textColor(Color(0, 0, 0, 1))

userView:addView(nameLabel)

--年龄
ageLabel = Label()
ageLabel:text("20"):fontSize(16):textColor(Color(255, 0, 0, 1))

userView:addView(ageLabel)

window:addView(ageLabel:superview())