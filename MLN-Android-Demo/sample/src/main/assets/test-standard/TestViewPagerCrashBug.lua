datasouce = {
    headIconName = "http://img.momocdn.com/album/4F/CF/4FCFA0D2-95E8-3C09-3760-142E6916CA1B20170701_S.jpg",
    summary = "安全等级：高",
    sections = {
        {
            sectionTitle = "通过以下设置可以提高安全等级",
            items = {
                {
                    iconName = "http://seopic.699pic.com/photo/50035/0520.jpg_wh1200.jpg",
                    title = "密码修改——1——100",
                    subtitle = nil,
                    height = 100,
                },
                {
                    iconName = "http://seopic.699pic.com/photo/50027/8874.jpg_wh1200.jpg",
                    title = "手机绑定——2——300",
                    subtitle = "已绑定",
                    height = 300,
                },
                {
                    iconName = "http://seopic.699pic.com/photo/50042/3858.jpg_wh1200.jpg",
                    title = "证件信息——3——100",
                    subtitle = "未绑定",
                    height = 100,
                },
                {
                    iconName = "http://seopic.699pic.com/photo/50034/3685.jpg_wh1200.jpg",
                    title = "登录保护--4--100",
                    subtitle = "已开启",
                    height = 100,
                },
                {
                    iconName = "http://img.momocdn.com/feedvideo/B4/9A/B49AB85D-34C8-0063-9F05-B23678D41D6C20180425_L.webp",
                    title = "登录保护--4--100",
                    subtitle = "已开启",
                    height = 100,
                },
                {
                    iconName = "http://img.momocdn.com/feedvideo/B4/9A/B49AB85D-34C8-0063-9F05-B23678D41D6C20180425_L.webp",
                    title = "登录保护--4--100",
                    subtitle = "已开启",
                    height = 100,
                },
            }
        },

    }
}

-- viewPager
local viewPager = ViewPager()
viewPager:bgColor(Color(105, 105, 105, 1))
viewPager:frame(Rect(0, 50, window:width(), 200))

viewPager:aheadLoad(true)
viewPager:autoScroll(true)
viewPager:recurrence(true)


--viewPager:setPreRenderCount(1)
viewPager:frameInterval(1.5)

--viewPager:showIndicator(true)

window:addView(viewPager)


-- adapter
local adapter = ViewPagerAdapter()


adapter:getCount(function()
    return #datasouce.sections[1].items;
end)


adapter:reuseId(function(position)
    return "same"
end)


adapter:initCellByReuseId("same" ,function(cell, position)
    cell.bgImage = ImageView():contentMode(ContentMode.SCALE_ASPECT_FIT):width(100):height(200)
    cell.contentView:cornerRadius(8)
    cell.contentView:bgColor(Color(255, 0, 0, 1))
    cell.contentView:addView(cell.bgImage)
end)


adapter:fillCellDataByReuseId("same" ,function(cell, position)
    --local normalCell = require("ui.demo.cells.ViewPagerCell")
    local section = datasouce.sections[1]
    local items = section.items;
    local detailItem = items[position]
     cell.bgImage:image(detailItem.iconName)

    cell.bgImage:onClick(function()
        --print('bgimage click')
    end)

end)

-- viewPager method
viewPager:endDragging(function(position)
    --print("endDragging position:", position)
end)


viewPager:cellWillAppear(function(cell, position)
    print("appear == ", position)
end)


viewPager:cellDidDisappear(function(cell, position)
    print("dis -- ", position)
end)

viewPager:adapter(adapter)
