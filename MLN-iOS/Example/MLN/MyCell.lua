--1

_argo_model_key_ = {"model"}

require("packet/BindMeta")
if model== nil then
model= BindMeta("model")
end
if ui_views == nil then
ui_views=setmetatable({}, { __mode = 'v'})
BindMetaCreateFindGID(ui_views)
end
local vwj1 = HStack()
ui_views.vwj1 = vwj1
vwj1:marginTop(10)
vwj1:marginLeft(10)
vwj1:width(394)
--vwj1:height(80)
vwj1:bgColor(Color(0, 255, 0, 1))
local vwj2 = Label()
ui_views.vwj2 = vwj2
vwj2:lines(0)
vwj2:text(model.title.__get)
model.title.__watch=function(new)
vwj2:text(new)
end
vwj2:padding(12, 18, 12, 18)
vwj2:marginLeft(10)
vwj1:children({vwj2})
window:addView(vwj1)
