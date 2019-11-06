local dataSource = Array()

local tableView = TableView()
tableView:width(window:width())
tableView:height(window:height())
window:addView(tableView)

local adapter = TableViewAdapter()
tableView:adapter(adapter)
adapter:sectionCount(function()
    return 1
end)
adapter:rowCount(function (sectionsID)
    return dataSource:size()
end)
adapter:reuseId(function(section,row)
    return 'a'
end)
adapter:initCellByReuseId('a',function(cell)
	local v = cell.contentView
	v:bgColor(Color(255,0,0,0.15))
	cell.label = Label()
    cell.label:textColor(Color(255,255,255,1))
    cell.label:fontSize(20)
    cell.label:lines(0)
    cell.label:bgColor(Color(0,0,0,0.15))
    cell.label:width(v:width())
    cell.contentView:flexChild(cell.label)
end)

adapter:fillCellDataByReuseId('a',function(cell,sectionId,row)
	local item = dataSource:get(row)
	-- if item then
		cell.label:text(item:fieldB())
		cell.label:height(item:fieldA())
	-- end
end)

adapter:heightForCell(function(section, row)
     local item = dataSource:get(row)
     return item:fieldA() * 4 or 0;
end)

function newItem(num, text)
	local db = TestDB()
	db:fieldA(num)
	db:fieldB(text)
	return db
end

function insertMessage(num, text)
	dataSource:add(newItem(num, text))
    -- tableView:insertCellAtRow(dataSource:size(),1)
     tableView:insertRow(dataSource:size(),1,true)
end

local b = Label()
b:text('new item')
b:x(0)
b:y(100)
b:width(100)
b:height(50)
b:bgColor(Color(255,255,0,1))
b:onClick(function ()
	local num = math.random(20)
	local text = 't:'
	for i=1,num do
		text = text..'aa'
	end
	insertMessage(num, text)
end)
window:addView(b)

local b1 = Label()
b1:text('save')
b1:x(0)
b1:y(200)
b1:width(100)
b1:height(50)
b1:bgColor(Color(255,255,0,1))
b1:onClick(function ()
	local start = os.time()
	local success = DBUtils:insertList(dataSource)
	print('save to db ', success, (os.time() - start))
end)
window:addView(b1)

local b2 = Label()
b2:text('error')
b2:x(0)
b2:y(300)
b2:width(100)
b2:height(50)
b2:bgColor(Color(255,255,0,1))
b2:onClick(function ()
	dataSource.get(1)
end)
window:addView(b2)

local start = os.time()
local dblist = DBUtils:queryList(TestDB())
if dblist then
	print('get from db ', (os.time() - start))
	dataSource = dblist
	tableView:reloadData()
else
	print('read from db failed')
end