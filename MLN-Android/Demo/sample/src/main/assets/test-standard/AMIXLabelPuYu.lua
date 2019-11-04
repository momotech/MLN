label = MixLabel():marginTop(150)

label:text("我是中国人，哈哈哈哈哈哈")

links = Array()

function getLink(text,action,color)
    local link = Map()

    if text ~= nil then
        link:put("text",text)
    end

    if action ~= nil then
        link:put("action",action)
    end

    if color ~= nil then
        link:put("color",color)
    end

    return link
end

links:add(getLink("🎞️陌陌影集","",""))
links:add(getLink("没事件","","255,20,147"))
links:add(getLink("青色事件gogogo","gogogo","0,255,255"))
links:add(getLink("默认事件亮色aiyo","aiyo",""))
links:add(getLink("普通2","",""))
links:add(getLink("绿色feiya","feiya","(60,179,113)"))
links:add(getLink("我也是醉了","",""))






--[[links:add(getLink("没事件","",  Color(211, 211, 211, 1))   )
links:add(getLink("青色事件gogogo","gogogo",  Color(255, 100, 211, 1))   )
links:add(getLink("默认事件亮色aiyo","aiyo",  Color(200, 100, 50, 1))     )
links:add(getLink("普通2","",  Color(60, 80, 98, 178))  )]]






label:setLinksCallback(links,function(index,link)

    print("点击了",index,link)

    if link ~= nil then
        local text = link:get("text") or ""
        Toast(text)
    end

end)


window:addView(label)


changeLabel = Lab