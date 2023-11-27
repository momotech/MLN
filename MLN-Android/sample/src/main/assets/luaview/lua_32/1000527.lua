-- 横向线性容器
-- linear = LinearLayout():setGravity(Gravity.CENTER)
-- 纵向线性容器
function white(num)
	return Color(num, num, num, 1)
end

imageWidth = 55
-- 宽度为屏幕宽度，高73pt，在屏幕中居中显示，背景浅灰
contentView = LinearLayout()
	:width(MeasurementType.MATCH_PARENT)
	:height(MeasurementType.WRAP_CONTENT)
	:setGravity(Gravity.CENTER)
	:bgColor(white(250))	-- 宽高自适应

-- 宽高均为55pt，纵向居中显示，左边距15pt，切圆角，背景浅灰
imageView = ImageView()
	:width(imageWidth)
	:height(imageWidth)
	:setGravity(Gravity.CENTER)
	:marginLeft(15)
	:cornerRadius(imageWidth/2)
	:bgColor(white(240))

-- 作为label和btn的父视图，宽度充满父视图，纵向居中显示，背景白
linear = LinearLayout()
	:width(MeasurementType.MATCH_PARENT)
	:setGravity(Gravity.CENTER)
	:bgColor(white(255))

-- 宽度充满父视图，纵向居中，左边距8pt，字体设置
label = Label()
	:width(MeasurementType.MATCH_PARENT)
	:lines(0)
	:setGravity(Gravity.CENTER)
	:marginLeft(8)
	:textColor(white(50))
	:text("小宇宙")
	:bgColor(white(240))

-- 宽66pt，高30pt，切圆角，纵向居中，右边距15pt，优先级为1（相对于label优先计算位置），字体等设置
btn = Label()
	:width(66)
	:height(30)
	:cornerRadius(15)
	:setGravity(Gravity.CENTER)
	:marginRight(15)
	:priority(1)
	:textColor(white(255))
	:textAlign(TextAlign.CENTER)
	:bgColor(Color(3, 214, 228, 1))
	:text("去完成")

linear:addView(label):addView(btn)
contentView:addView(imageView):addView(linear)
window:addView(contentView)


function updateView(map)
    --这些绑定数据最好 原生直接持有 udmap和bindable table 直接持有 否则会频繁的创建
    --map的改变 如果table改为不是每次初始化  则会造成map改变 table里的数据没改变
    label:text(map:get("title"))
    btn:onClick(function()
        str="附近被点击"
        map:put("title",str)
        label:text(map:get("title"))
    end)

end