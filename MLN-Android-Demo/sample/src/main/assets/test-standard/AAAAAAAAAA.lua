-- Toast("IOS:请用陌陌客户端扫码",1)

--[[local array = Array()
array:add('附近动态')
array:add('附近的人')
array:add('附近直播')
array:add('item4')
array:add('item5')
array:add('item6')
array:add('item7')]]


local array = {'附近动态','附近的人','附近直播','item4','item5','item6','item8'}


print('----',MBit:bor(1,2))

-- array:add('item8')
-- array:add('item9')
-- array:add('item10')
-- array:add('item11')
-- array:add('item12')
-- array:add('item13')
-- array:add('item14')
print(array)

tabSegment = TabSegmentView(Rect(0, 400, window:width(), 100), array)
tabSegment:relatedToViewPager(viewPager)
tabSegment:bgColor(Color():hex(0xffff00):alpha(1))
tabSegment:selectScale(1.6)
tabSegment:normalFontSize(15)
tabSegment:setTapBadgeNumAtIndex(30, 3)
window:addView(tabSegment)
-- TODO iOS_SDK_1.1.29.2，暂不支持'setTabSelectedListener'调用方式
--tabSegment:addTabSelectedListener(function(index)
-- print(index)
--end)

local darkLabel = Label()
darkLabel:y(300):width(100):height(50)
darkLabel:fontSize(16)

darkLabel:setTextBold()

darkLabel:text("IOS---dark44")
darkLabel:bgColor(Color():hex(0xffaa00):alpha(1))
darkLabel:addShadow(Color(255,0,0,1), Size(0,0),25,1)




numberCellText = "0\n9\n8\n7\n6\n5\n4\n3\n2\n1\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0"
cellSizee = StringUtil:sizeWithContentFontNameSize(numberCellText,'molivehomeonline.ttf',70)

Toast(   'width = '..tostring(cellSizee:width())  )

print('cell size width: ----',cellSizee:width())




hex= 0xebebeb
local r = MBit:band(MBit:shr(hex, 16), 0xff)
local g = MBit:band(MBit:shr(hex, 8), 0xff)
local b = MBit:band(MBit:shr(hex, 0), 0xff)

print('rrrrrr --- ',MBit:shr(hex, 16))
print('band --- ',MBit:band(MBit:shr(hex, 16), 0xff))


local color88 = Color(r, g, b, 1)

local lightLabel = Label()
lightLabel:y(50):width(100):height(50):marginLeft(100)
lightLabel:fontSize(16)

lightLabel:setTextBold()

lightLabel:text("lightttt555")
-- lightLabel:bgColor(Color():hex(0xffaa00):alpha(1))
 lightLabel:bgColor(color88)
lightLabel:addShadow(Color(255,0,0,1), Size(0.2,0.2),10,1)




window:setStatusBarStyle(StatusBarStyle.Default);
preStatusBarFontColor = window:getStatusBarStyle();



darkLabel:onClick(function()
     window:setStatusBarStyle(preStatusBarFontColor);
    --window:setStatusBarStyle(StatusBarStyle.Default);
end)

lightLabel:onClick(function()
    -- window:setStatusBarStyle(preStatusBarFontColor);
    window:setStatusBarStyle(StatusBarStyle.Light);
end)


window:addView(darkLabel)
window:addView(lightLabel)


local  text = Clipboard:getTextWithClipboardName("test.www")
--Toast("读取:"..text,2)