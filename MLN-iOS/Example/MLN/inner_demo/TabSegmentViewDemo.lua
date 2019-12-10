
---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by momo.
--- DateTime: 2019/1/24 下午6:00
---


function setupViewPager()
dataSource = {"1", "2", "3", "4", "5"}

viewPager = ViewPager()
viewPager:frame(Rect(0, 50, window:width(), window:height() - 50))
adapter = ViewPagerAdapter()

adapter:getCount(function() --设置cell数量回调
return #dataSource
end)

adapter:initCell(function (cell) --设置初始化cell的回调
cell.label = Label():width(200):height(200)
cell.label:marginTop(200):marginLeft(80)
cell.label:fontSize(40)
cell.label:textAlign(TextAlign.CENTER)
cell.contentView:cornerRadius(10):clipToBounds(true) --圆角
cell.contentView:bgColor(Color(100, 100, 100, 0.5))
cell.contentView:addView(cell.label)
end)

adapter:fillCellData(function (cell, position) --设置初始化cell数据的回调
local data = dataSource[position]
cell.label:text(data)
end)

viewPager:setPageClickListener(function (position) --设置点击指定页的回调
Toast("Click position: "..tostring(position),1)
end)

viewPager:autoScroll(false) --是否自动滚动
viewPager:showIndicator(true)
viewPager:adapter(adapter)
window:addView(viewPager)
end

-- 创建viewPager
setupViewPager()

-----------以下为创建tab segment--------------
local array = Array()
array:add('附近动态')
array:add('附近的人')
array:add('附近直播')
array:add('item4')
array:add('item5')
array:add('item6')
array:add('item7')
array:add('item8')
array:add('item9')
array:add('item10')
array:add('item11')
array:add('item12')
array:add('item13')
array:add('item14')
print(array)

-- android的array暂不支持lua table
tabSegment = TabSegmentView(Rect(0, 80, window:width(), 50), array)
tabSegment:relatedToViewPager(viewPager)
tabSegment:bgColor(Color():hex(0xffff00):alpha(1))
tabSegment:selectScale(1.6)
tabSegment:normalFontSize(15)
tabSegment:setTapBadgeNumAtIndex(30, 3)
window:addView(tabSegment)

tabSegment:setTabSelectedListener(function(index)
print(">>> 选中 tab index =", index)
end)

local label4 = Label()
label4:y(200):width(200):height(50)
label4:fontSize(16)
label4:text("点击选中第2个 tab")
label4:bgColor(Color():hex(0xffaa00):alpha(1))
label4:onClick(function()
print('>>>> currentIndex:', tabSegment:currentIndex())
-- 动画效果选中index 2
tabSegment:setCurrentIndexAnimated(2)

-- index 4上设置badge num为20
tabSegment:setTapBadgeNumAtIndex(20, 4)
-- index 1上展示红点
tabSegment:setRedDotHiddenAtIndex(1, true)

-- 隐藏index 3上的badge num
tabSegment:setTapBadgeNumAtIndex(0, 3)
end)
window:addView(label4)
