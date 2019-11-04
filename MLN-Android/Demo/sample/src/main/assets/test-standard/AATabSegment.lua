Toast("IOS:请用陌陌客户端扫码",1)

--[[local array = Array()
array:add('附近动态')
array:add('附近的人')
array:add('附近直播')
array:add('item4')
array:add('item5')
array:add('item6')
array:add('item7')]]


local array = {'附近动态','附近的人','附近直播','item4','item5','item6','item8'}


local http1 = LHttp()
print("http1: ", http1)
http1:setBaseUrl('http://api.immomo.com')

-- array:add('item8')
-- array:add('item9')
-- array:add('item10')
-- array:add('item11')
-- array:add('item12')
-- array:add('item13')
-- array:add('item14')
print(array)

tabSegment = TabSegmentView(Rect(0, 400, window:width(), 100), array)


tabSegment:setTabScrollingListener(function(progress)
    print('progress = ',progress)
end)


tabSegment:relatedToViewPager(viewPager)


tabSegment:bgColor(Color():hex(0xffff00):alpha(1))
tabSegment:selectScale(1.6)
tabSegment:normalFontSize(15)
tabSegment:setTapBadgeNumAtIndex(30, 3)





tabSegment:selectedColor(Color(255,0,0))
tabSegment:tintColor(Color(0,0,255))
tabSegment:indicatorColor(Color(0,255,0))


window:addView(tabSegment)
-- TODO iOS_SDK_1.1.29.2，暂不支持'setTabSelectedListener'调用方式
--tabSegment:addTabSelectedListener(function(index)
-- print(index)
--end)

local label4 = Label()
label4:y(100):width(MeasurementType.MATCH_PARENT):height(50)
label4:fontSize(16)
label4:bgImage('abc')

local imageStyle = StyleString('http://img.momocdn.com/album/4F/CF/4FCFA0D2-95E8-3C09-3760-142E6916CA1B20170701_S.jpg'):showAsImage(Size(10,10))

local styleMain = StyleString('style1/'):append(imageStyle):append(StyleString('style2/')):append(imageStyle):append(StyleString('end'));

--label4:setTextBold()

label4:text("IOS:客户端扫码")


--label4:styleText(styleMain,label4)
label4:styleText(styleMain)



-- label4:bgColor(Color():hex(0xffaa00):alpha(1))

label4:onClick(function()
    -- print('gggg currentIndex:', tabSegment:currentIndex());
    -- tabSegment:setCurrentIndexAnimated(2)
    -- tabSegment:setTapBadgeNumAtIndex(20, 4)
    -- tabSegment:setRedDotHiddenAtIndex(3)

    --tabSegment:selectedColor(Color(0,255,0))

    tabSegment:tintColor(Color(255,0,0,1.0))
    tabSegment:indicatorColor(Color(0,0,255))

    print("tintColor() == ",tabSegment:tintColor())

end)
window:addView(label4)



arr1 = Array()
arr1:add(1):add(2):add(3):add(4):add(5):add(6)


subArray= arr1:subArray(4,6)
print('subArry size = ',subArray:size())
subArray:add(9)
print('subArry size = ',subArray:size())


arr2= arr1:copyArray(arr1)
print('copyArray----',arr2:size(),arr2:get(2))




arr2:add(7)
arr2:add('long')
print('add value to new array = ',arr2:size(),arr2:get(7),arr2:get(arr2:size()))

print('address = ',arr1,arr2)




statusTrueOrFalse,returnResult = pcall(function(first,second,third)
    print('pcall  invoke   test -----',first,second,third)
    return 'return-result'
end,2222,3333,55555)

print(statusTrueOrFalse)
print(returnResult)