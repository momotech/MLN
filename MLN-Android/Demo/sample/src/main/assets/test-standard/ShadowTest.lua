

contentView = View():width(window:width()-15*2):marginLeft(15):height(99.5)


local startColor  = Color(255,255,255,0.09)
local endColor  = Color(255,255,255,0.15)

contentView:setGradientColor(startColor,endColor,true)
contentView:borderColor(Color(59,202,218,0.12))
contentView:borderWidth(1.5)
contentView:marginTop(100)

contentView:cornerRadius(20)

contentView:addShadow(Color(
        255,255,255,0.1
),Size(0,3),6,1)

window:addView(contentView)