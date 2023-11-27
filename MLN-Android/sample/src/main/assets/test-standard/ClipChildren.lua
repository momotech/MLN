--
--local p1=LinearLayout():height(100)
--local p2=LinearLayout():height(100)
--local image=ImageView():height(200):width(200):image("http://img.momocdn.com/album/82/B3/82B3827C-0097-FF87-BD17-CEB126F52CEF20190503_S.jpg")
--p2:addView(image)
--p1:addView(p2)
--window:addView(p1)
datas = {
    {
        theme = 101,
        desc = "Apple"
    },
    {
        theme = 101,
        desc = "Pear"
    },
    {
        theme = 201,
        img_url = "http://img0.imgtn.bdimg.com/it/u=383546810,2079334210&fm=26&gp=0.jpg"
    },
    {
        theme = 201,
        img_url = "http://img0.imgtn.bdimg.com/it/u=383546810,2079334210&fm=26&gp=0.jpg"
    },
    {
        theme = 101,
        desc = "Orange"
    },
    {
        theme = 201,
        img_url = "http://img0.imgtn.bdimg.com/it/u=383546810,2079334210&fm=26&gp=0.jpg"
    }
}


-- item类型枚举
local TYPE_CELL = {
    TEXT = "TYPE_CELL_TEXT",
    IMG = "TYPE_CELL_IMG"
}

--初始化适配器
function initAdapter()
    -----------------------TableViewAutoFitAdapter------------------------------
    --adapter = TableViewAutoFitAdapter();--根据布局高度自适应
    -----------------------TableViewAdapter-------------------------------------
    adapter = TableViewAdapter();
    ---------TableViewAdapter需自行计算item高度，并在heightForCell方法中返回---------
    adapter:heightForCell(function(section, row)
        return 120
    end)
    -- 组数，一维list返回1
    adapter:sectionCount(function()
        return 1;
    end);

    ------------------------------------ 子View个数 ------------------------------

    -- 返回tableview中子View的个数，一维时行数取决于datas大小，和section无关
    adapter:rowCount(function(section)
        if datas == nill or #datas == 0 then
            return 0;
        else
            return #datas;
        end
    end);

    ------------------------------------ 子View类型 ------------------------------

    -- 返回当前位置子View的类型标识，一维时取决于position对应的data，和section无关
    adapter:reuseId(function(section, position)
        local theme = datas[position].theme;
        local type = nil;
        if theme then
            if theme == 101 then
                -- 布局一：显示文本
                type = TYPE_CELL.TEXT;
            elseif theme == 201 then
                -- 布局二：显示图片
                type = TYPE_CELL.IMG;
            end
        end
        return type;
    end);

    ------------------------------------ 创建子View ------------------------------

    -- 初始化指定类型：TYPE_CELL.TEXT的子View（仅描述View，不描述业务数据的绑定关系）
    adapter:initCellByReuseId(TYPE_CELL.TEXT, function(cell)
        cell.p1 = LinearLayout():width(400):height(100):bgColor(Color(100, 50, 100))
        local p2 = LinearLayout():height(100)
        local image = ImageView():height(200):width(200):image("http://img.momocdn.com/album/82/B3/82B3827C-0097-FF87-BD17-CEB126F52CEF20190503_S.jpg")
        p2:addView(image)
        cell.p1:addView(p2)
        cell.contentView:addView(cell.p1)
    end);

    -- 初始化指定类型：TYPE_CELL.IMG的子View（仅描述View，不描述业务数据的绑定关系）
    adapter:initCellByReuseId(TYPE_CELL.IMG, function(cell)
        cell.rowContainer = View():width(MeasurementType.MATCH_PARENT)
                                  :height(MeasurementType.WRAP_CONTENT)
                                  :setGravity(Gravity.CENTER);
        cell.iv = ImageView():width(60):height(60)
                             :cornerRadius(45)
                             :contentMode(ContentMode.SCALE_TO_FILL)
                             :setGravity(Gravity.CENTER);
        cell.rowContainer:addView(cell.iv);

        cell.contentView:addView(cell.rowContainer);
    end);
    -------------------------------- 绑定子View与业务值 --------------------------

    -- 描述指定类型：TYPE_CELL.TEXT的子View在指定位置上与业务数据的绑定关系
    adapter:fillCellDataByReuseId(TYPE_CELL.TEXT, function(cell, section, row)
        cell.tv:text(datas[row].desc);
    end);

    -- 描述指定类型：TYPE_CELL.IMG的子View在指定位置上与业务数据的绑定关系
    adapter:fillCellDataByReuseId(TYPE_CELL.IMG, function(cell, section, row)
        cell.iv:image(datas[row].img_url);
    end);

    -------------------------------- 绑定子View点击事件 --------------------------

    -- 设置指定类型：TYPE_CELL.TEXT的子View在点击时的回调
    adapter:selectedRowByReuseId(TYPE_CELL.TEXT, function(cell, section, row)
        print("点击了：" .. TYPE_CELL.TEXT .. "-" .. tostring(row));
    end);

    -- 设置指定类型：TYPE_CELL.IMG的子View在点击时的回调
    adapter:selectedRowByReuseId(TYPE_CELL.IMG, function(cell, section, row)
        print("点击了：" .. TYPE_CELL.IMG .. "-" .. tostring(row));
    end);
    return adapter;
end


--tableview初始化
tableView = TableView(true, true)
        :width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT);
--下拉刷新事件回调
tableView:setRefreshingCallback(
        function()
            print("开始刷新")
            System:setTimeOut(function()
                --2秒后结束刷新
                print("结束刷新了")
                tableView:stopRefreshing()
            end, 2)
        end)
--上拉加载事件回调
tableView:setLoadingCallback(function()
    print("开始加载")
    System:setTimeOut(function()
        --2秒后结束加载
        print("结束加载")
        tableView:stopLoading()
        --已加载全部
        tableView:noMoreData()
    end, 2)

end)
local adapter = initAdapter();--adapter初始化方法，具体实现稍后会介绍
tableView:adapter(adapter);
window:addView(tableView);