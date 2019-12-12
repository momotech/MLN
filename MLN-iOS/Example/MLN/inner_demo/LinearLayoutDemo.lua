local imageUrl = "http://img0.imgtn.bdimg.com/it/u=383546810,2079334210&fm=26&gp=0.jpg"
contentView = View():setGravity(Gravity.CENTER)
contentView:bgColor(Color(34, 66, 121, 1)):width(MeasurementType.MATCH_PARENT):height(88)
window:addView(contentView)

imageView = ImageView():width(60):height(60)
imageView:contentMode(ContentMode.SCALE_TO_FILL):setGravity(Gravity.CENTER_VERTICAL):cornerRadius(35):marginLeft(10)
imageView:setImageUrl(imageUrl)
contentView:addView(imageView)

infoView = LinearLayout(LinearType.VERTICAL)
infoView:bgColor(Color(255, 252, 153, 0.5)):width(MeasurementType.MATCH_PARENT):height(70):setGravity(MBit:bor(Gravity.CENTER_VERTICAL, Gravity.RIGHT)):marginRight(8):padding(3, 8, 3, 8):marginLeft(98)
contentView:addView(infoView)

nameTimeView = View()
nameTimeView:bgColor(Color(94, 87, 46, 70)):width(MeasurementType.MATCH_PARENT):marginTop(5)
infoView:addView(nameTimeView)

nameLabel = Label()
nameLabel:text("我是一头蒜"):marginLeft(5):setGravity(Gravity.CENTER_VERTICAL)
nameTimeView:addView(nameLabel)

disTimeLb = Label()
disTimeLb:text("1.02km·3分钟前"):setGravity(MBit:bor(Gravity.CENTER_VERTICAL, Gravity.RIGHT)):fontSize(12)
nameTimeView:addView(disTimeLb)

baseLabelView = LinearLayout(LinearType.HORIZONTAL)
baseLabelView:bgColor(Color(95, 78, 79, 18)):width(MeasurementType.MATCH_PARENT):height(15):marginTop(8)
infoView:addView(baseLabelView)

ageLb = Label()
ageLb:bgColor(Color(172, 13, 56, 1)):height(12):setGravity(Gravity.CENTER_VERTICAL):text("26岁26岁26岁26岁26岁"):fontSize(10):cornerRadius(8):textAlign(TextAlign.CENTER)
baseLabelView:addView(ageLb)

starLb = Label()
starLb:bgColor(Color(28, 80, 199, 18)):priority(2):height(12):setGravity(Gravity.CENTER_VERTICAL):text("白羊座白羊座白羊座"):fontSize(10):cornerRadius(8):marginLeft(8):textAlign(TextAlign.CENTER)
baseLabelView:addView(starLb)

workLb = Label()
workLb:bgColor(Color(128, 8, 19, 180)):priority(1):height(12):setGravity(Gravity.CENTER_VERTICAL):text("互联网互联网互联网"):fontSize(10):cornerRadius(8):marginLeft(8):textAlign(TextAlign.CENTER)
baseLabelView:addView(workLb)

weightView = LinearLayout(LinearType.HORIZONTAL):marginTop(8)
infoView:addView(weightView)

ageLb = Label()
ageLb:bgColor(Color(172, 13, 56, 1)):weight(1):height(12):setGravity(Gravity.CENTER_VERTICAL):text("26岁26岁26岁26岁26岁"):fontSize(10):cornerRadius(8):textAlign(TextAlign.CENTER)
weightView:addView(ageLb)

starLb = Label()
starLb:bgColor(Color(28, 80, 199, 18)):weight(2):height(12):setGravity(Gravity.CENTER_VERTICAL):text("白羊座白羊座白羊座"):fontSize(10):cornerRadius(8):marginLeft(8):textAlign(TextAlign.CENTER)
weightView:addView(starLb)

workLb = Label()
workLb:bgColor(Color(128, 8, 19, 180)):weight(3):height(12):setGravity(Gravity.CENTER_VERTICAL):text("互联网互联网互联网"):fontSize(10):cornerRadius(8):marginLeft(8):textAlign(TextAlign.CENTER)
weightView:addView(workLb)