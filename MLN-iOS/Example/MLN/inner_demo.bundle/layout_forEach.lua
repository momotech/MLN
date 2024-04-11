--1
ui_views = {}
local cnt  = 1
local window_1 = HStack()
ui_views.window_1 = window_1
window_1:bgColor(Color(255, 0, 0, 0.2))

local window_1_foreach_1 = function(i, item)
return (function()
local window_1_var_0 = VStack()
ui_views.window_1_var_0 = window_1_var_0
    
local window_1_var_0_1 = Label()
        local key = 'window_1_var_0_1_'..i
ui_views[key] = window_1_var_0_1
window_1_var_0_1:text(item.name)
        
        DataBinding:bindArrayData("userDataModel.source", i, "name", function(new,old)
                         ui_views[key]:text(new)
                         end)
        
        
local window_1_var_0_2 = Label()
ui_views.window_1_var_0_2 = window_1_var_0_2
window_1_var_0_2:text(item.title)
window_1_var_0_2:onClick(function()

                         cnt = cnt  +  1
                         local n = "change "..cnt
                         DataBinding:updateArrayData("userDataModel.source", i, "name", n)
                         
                         
end)
window_1_var_0:children({window_1_var_0_1, window_1_var_0_2})
window_1_var_0:mainAxisAlignment(MainAxisAlignment.SPACE_EVENLY)
return window_1_var_0
end)()


end
local window_1_subFunc_1 = function()
local window_1_foreach_var = {}
for _i, _v in ipairs(DataBinding:get("userDataModel.source")) do
window_1_foreach_var[_i] = window_1_foreach_1(_i, _v)
end
return window_1_foreach_var
end
local window_1_1 = Label()
ui_views.window_1_1 = window_1_1
window_1_1:text(DataBinding:get("userDataModel.name"))
DataBinding:bind("userDataModel.name", function(new, old)
    window_1_1:text(new)
end)
local window_1_addView = function()
local window_1_viewsTable = {}
local add = function(_view_)
if type(_view_) == "table" then
for _i, _v in ipairs(_view_) do
table.insert(window_1_viewsTable, _v)
end
else
table.insert(window_1_viewsTable, _view_)
end
end
add(window_1_1)
add(window_1_subFunc_1())
window_1:children(window_1_viewsTable)
end
window_1_addView()
DataBinding:bind("userDataModel.source", function(new, old)
window_1:removeAllSubviews()
window_1_addView()
end)
window_1:width(MeasurementType.MATCH_PARENT)
window_1:height(88)
window_1:setGravity(Gravity.CENTER_VERTICAL)
window_1:mainAxisAlignment(MainAxisAlignment.SPACE_BETWEEN)
window_1:crossAxisAlignment(CrossAxisAlignment.CENTER)
window_1:onClick(function()
 local s={}
for i=1,3 do
local t={}
t.name="change " .. i
s[i]=t
end
userData.source=s
end)
window:addView(window_1)
return {}, true
