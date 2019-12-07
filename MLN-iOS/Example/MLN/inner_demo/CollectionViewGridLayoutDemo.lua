
screen_h = window:height() - 64

window:bgColor(Color(255, 255, 255, 1))

cellSize = {Size(111, 300), Size(111, 200), Size(111, 200), Size(111, 200), Size(365, 200), Size(111, 200),Size(111, 200), Size(111, 200), Size(111, 200), Size(111, 200), Size(111, 200), Size(111, 200), Size(111, 200), Size(111, 200), Size(365, 200), Size(111, 200),Size(111, 200), Size(111, 200), Size(111, 200), Size(111, 200)}

Data = {
sections = {
{
items = {
{
text = "section || row ----- section 1 row 1"
},
{
text = "section || row ----- section 1 row 2"
},
{
text = "section || row ----- section 1 row 3"
},
{
text = "section || row ----- section 1 row 4"
},
{
text = "section || row ----- section 1 row 5"
},
{
text = "section || row ----- section 1 row 6"
},
{
text = "section || row ----- section 1 row 7"
},
{
text = "section || row ----- section 1 row 8"
},
{
text = "section || row ----- section 1 row 9"
},
{
text = "section || row ----- section 1 row 10"
},
{
text = "section || row ----- section 1 row 11"
},
{
text = "section || row ----- section 1 row 12"
},
{
text = "section || row ----- section 1 row 13"
},
{
text = "section || row ----- section 1 row 14"
},
{
text = "section || row ----- section 1 row 15"
},
{
text = "section || row ----- section 1 row 16"
},
{
text = "section || row ----- section 1 row 17"
},
{
text = "section || row ----- section 1 row 18"
},
{
text = "section || row ----- section 1 row 19"
},
{
text = "section || row ----- section 1 row 20"
}
}
}
}
}

collectionView =  CollectionView()
collectionView:frame(Rect(0, 64, window:width(), screen_h))
collectionView:bgColor(Color(255, 255, 255, 1))

rowCount = 20

--- layout
layout = CollectionViewGridLayout()
layout:spanCount(3)
layout:lineSpacing(20)
layout:itemSpacing(10)
layout:layoutInset(5, 5, 5, 5)
collectionView:layout(layout)

--- adapter
adapter = CollectionViewAutoFitAdapter()
adapter:sectionCount(function()
local sections = Data.sections
print(">>>>> sections  ---- ", #sections)
return #sections
end)

adapter:rowCount(function(sectionidx)
local section = Data.sections[sectionidx]
print(">>>>> items  ---- ", section)
return #section.items
end)

adapter:initCell(function(cell)
local contentView = cell.contentView
contentView:bgColor(Color(57, 175, 202, 1))
cell.image = ImageView()
cell.image:width(MeasurementType.MATCH_PARENT):height(MeasurementType.MATCH_PARENT)
cell.image:cornerRadius(10)
contentView:addView(cell.image)
cell.label = Label()
cell.label:textAlign(TextAlign.CENTER)
cell.label:lines(0):width(100)
cell.label:textColor(Color(255,0,0,1))
contentView:addView(cell.label)
end)

adapter:fillCellData(function(cell, section, row)
local contentView = cell.contentView
--cell.image:image("https://yyb.gtimg.com/aiplat/page/product/visionimgidy/img/demo6-16a47e5d31.jpg")
--cell.label:text("Reuse cell | section" .. section .. "row" .. row)

local sections = Data.sections[section]
local item = sections.items[row]
print(">>>>> item", item)
cell.label:text(item.text)
end)

adapter:selectedRow(function(cell, section, row)
local txt = "be selected, section:" .. section .. "row:" .. row
cell.label:text(txt)
end)

size = Size()
size:width(30)
size:height(100)

collectionView:adapter(adapter)
window:addView(collectionView)

leftLinear = LinearLayout(LinearType.VERTICAL)
leftLinear:setGravity(Gravity.CENTER_VERTICAL)
window:addView(leftLinear)

insertLabel = Label()
insertLabel:text("插入单行"):marginTop(10):height(50)
insertLabel:bgColor(Color(0,0,255,1))
insertLabel:onClick(function()
--rowCount = rowCount + 1
--collectionView:insertCellAtRow(1,1)

print("datasouce ------- ", Data.sections[1])
local section = Data.sections[1]
local count =  #section.items
value = {
text = "hello world, hello world, hello world, hello world，hello world",
}
table.insert(Data.sections[1].items, 1, value)
collectionView:insertCellAtRow(1, 1)
end)
leftLinear:addView(insertLabel)

deleteLabel = Label()
deleteLabel:text("删除单行"):marginTop(10):height(50)
deleteLabel:bgColor(Color(0,0,255,1))
deleteLabel:onClick(function()
table.remove(Data.sections[1].items, 1)
collectionView:deleteCellAtRow(1,1)
end)
leftLinear:addView(deleteLabel)

reloadLabel = Label()
reloadLabel:text("刷新单行"):marginTop(10):height(50)
reloadLabel:bgColor(Color(0,0,255,1))
reloadLabel:onClick(function()
collectionView:reloadAtRow(1,1)
end)
leftLinear:addView(reloadLabel)


rightLinear = LinearLayout(LinearType.VERTICAL)
rightLinear:setGravity(Gravity.CENTER_VERTICAL + Gravity.RIGHT)
window:addView(rightLinear)

insertsLabel = Label()
insertsLabel:text("插入十行"):marginTop(10):height(50)
insertsLabel:bgColor(Color(0,0,255,1))
insertsLabel:onClick(function()

value1 = {
text = "1hello world, hello world, hello world, hello world，hello world",
}
value2 = {
text = "2hello world, hello world, hello world, hello world，hello world",
}
value3 = {
text = "3hello world, hello world, hello world, hello world，hello world",
}
value4 = {
text = "4hello world, hello world, hello world, hello world，hello world",
}
table.insert(Data.sections[1].items, 1, value1)
table.insert(Data.sections[1].items, 2, value2)
table.insert(Data.sections[1].items, 3, value3)
table.insert(Data.sections[1].items, 4, value4)

rowCount = rowCount + 4
collectionView:insertCellsAtSection(1,1,4)
end)
rightLinear:addView(insertsLabel)

deletesLabel = Label()
deletesLabel:text("删除十行"):marginTop(10):height(50)
deletesLabel:bgColor(Color(0,0,255,1))
deletesLabel:onClick(function()
rowCount = rowCount - 3

table.remove(Data.sections[1].items, 1)
table.remove(Data.sections[1].items, 1)
table.remove(Data.sections[1].items, 1)
table.remove(Data.sections[1].items, 1)
collectionView:deleteCellsAtSection(1,1,4)
end)
rightLinear:addView(deletesLabel)

reloadsLabel = Label()
reloadsLabel:text("刷新多行"):marginTop(10):height(50)
reloadsLabel:bgColor(Color(0,0,255,1))
reloadsLabel:onClick(function()
collectionView:reloadData(1,1)
end)
rightLinear:addView(reloadsLabel)

topLinear = LinearLayout(LinearType.HORIZONTAL)
topLinear:setGravity(Gravity.CENTER_HORIZONTAL + Gravity.TOP)
window:addView(topLinear)

changeLabel = Label()
changeLabel:bgColor(Color(0,0,255,1))
changeLabel:text("变换布局"):marginTop(64):height(50)
changeLabel:onClick(function()
if collectionView:scrollDirection() == ScrollDirection.VERTICAL then
collectionView:scrollDirection(ScrollDirection.HORIZONTAL)
else
collectionView:scrollDirection(ScrollDirection.VERTICAL)
end

end)
topLinear:addView(changeLabel)


