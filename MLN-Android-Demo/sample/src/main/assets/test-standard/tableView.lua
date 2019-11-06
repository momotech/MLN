
local collectionView = TableView()
local adapter = TableViewAdapter()

print("keye 11111111")
adapter:initCell(function(cell)
    --print("keye 1:",cell)
    --print("keye 2:",cell,cell[1])
    --print("keye 3:",cell,cell.contentView)
    --print("keye 4:",cell,cell["contentView"])
    local titleLabel=View()
    titleLabel:width(80)
    titleLabel:height(30)
    titleLabel:bgColor(Color(0,0,0,1))
    --titleLabel:setMatchParent(true)
    --cell.bgImage:setMatchParent(true)
    print("----------", getmetatable(cell.contentView))
    cell.contentView:addView(titleLabel)

    --local haha={}
    --haha["nima"]=View();
    --
    --print("keye 5",haha[0], haha["nima"])

end)
adapter:fillCellData(function(cell, section, row)

end)
print("keye 222222")
count = 87
adapter:sectionCount(function()
    return 1
end)
adapter:rowCount(function(section)
    print("keye row1111111")
    return count
end)

print("keye 333333")

collectionView:adapter(adapter)

print("keye 444444")
collectionView:setRefreshingCallback(function()
    collectionView:stopRefreshing()
    collectionView:stopLoading()
    --collectionView:resetLoading()
    collectionView:reloadData()
end)

print("keye 555555")
collectionView:setLoadingCallback(function()
    count = count + 10
    collectionView:reloadData()
    collectionView:stopRefreshing()
    collectionView:stopLoading()
end)

print("keye 6666660..")
collectionView:width(300)
collectionView:height(800)
collectionView:bgColor(Color(123,123,123,1))
window:addView(collectionView)
collectionView:reloadData()
print("keye 7777777..")

function PrintTable( tbl , level, filteDefault)
    local msg = ""
    filteDefault = filteDefault or false
    level = level or 1
    local indent_str = ""
    for i = 1, level do
        indent_str = indent_str.."  "
    end

    print(indent_str .. "{")
    for k,v in pairs(tbl) do
        if filteDefault then
            if k ~= "_class_type" and k ~= "DeleteMe" then
                local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
                print(item_str)
                if type(v) == "table" then
                    PrintTable(v, level + 1)
                end
            end
        else
            local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
            print(item_str)
            if type(v) == "table" then
                PrintTable(v, level + 1)
            end
        end
    end
    print(indent_str .. "}")
end

--PrintTable(___Global_Native_Value, nil, nil)