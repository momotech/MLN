
dataSource = {
items = {
{
icon = "http://s.momocdn.com/w/u/others/2019/01/16/1547610372024-01.png",
text = "11111"
},
{
icon = "http://s.momocdn.com/w/u/others/2019/01/16/1547610372064-02.png",
text = "22222"
},
{
icon = "http://s.momocdn.com/w/u/others/2019/01/16/1547610372063-3.png",
text = "33333"
},
{
icon = "http://s.momocdn.com/w/u/others/2019/01/16/1547610372137-4.png",
text = "44444"
},
{
icon = "http://s.momocdn.com/w/u/others/2019/01/16/1547610372063-5.png",
text = "55555"
}
}
}

local viewPager = ViewPager()
viewPager:frame(Rect(0, 50, window:width(), window:height() - 50))
local adapter = ViewPagerAdapter()

adapter:getCount(function()  --设置cell数量回调
return #dataSource.items
end)

adapter:initCell(function (cell)  --设置初始化cell的回调
cell.bgImage = ImageView():contentMode(ContentMode.SCALE_ASPECT_FIT):width(200):height(200)
cell.bgImage:marginTop(200):marginLeft(80)
cell.contentView:cornerRadius(10):clipToBounds(true)  --圆角
cell.contentView:bgColor(Color(255, 0, 0, 0.5))
cell.contentView:addView(cell.bgImage)
end)

adapter:fillCellData(function (cell, position)  --设置初始化cell数据的回调
local items = dataSource.items[position]
cell.bgImage:image(items.icon)
end)

viewPager:setPageClickListener(function (position)  --设置点击指定页的回调
Toast("Click position: "..tostring(position),1)
end)

viewPager:autoScroll(true)  --是否自动滚动
viewPager:frameInterval(5)  --播放的周期
viewPager:showIndicator(true)

viewPager:adapter(adapter)
window:addView(viewPager)

local array = Array()
for _,v in ipairs(dataSource.items) do
array:add(v.text)
end

tabLayout = TabSegmentView(Rect(0,0,window:width(),50), array)
tabLayout:relatedToViewPager(viewPager, true)  --实现联动效果
tabLayout:setTabSelectedListener(function (index)  --设置tab选中的索引
Toast("select "..index,1)
end)
tabLayout:selectScale(1.6)  --选中时缩放比例
tabLayout:normalFontSize(15)  --默认字体大小
tabLayout:setTapBadgeNumAtIndex(30, 3)  --设置标注数

window:addView(tabLayout)

local label = Label():x(100):y(100):width(100):height(100):fontSize(16):textAlign(TextAlign.CENTER)
label:text("click"):bgColor(Color():hex(0xffff00):alpha(1))
label:onClick(function ()
tabLayout:setCurrentIndexAnimated(2)  --滚动到指定标签
tabLayout:setTapBadgeNumAtIndex(20, 4)  --设置标注数
tabLayout:setTapBadgeNumAtIndex(0, 3)  --隐藏标注
end)

window:addView(label)

