--1
require("packet/BindMeta")
require("packet/style")
if model== nil then
model= BindMeta("model")
end
if ui_views == nil then
ui_views=setmetatable({}, { __mode = 'v'})
BindMetaCreateFindGID(ui_views)
end
ui_class=__module.defModule("ui")
function ui_class:init(uiSuper)
self._view=uiSuper
self=__module.weakSelf(self)
local vwj1 = VStack(true)
self.vwj1 = vwj1
self.vwj1:marginTop(20)
self.vwj1:marginLeft(10)
self.vwj1:width(394)
self.vwj1:height(60)
self.vwj1:bgColor(Color(0, 255, 0, 1))
local vwj2 = Label()
self.vwj2 = vwj2
self.vwj2:lines(0)
self.vwj2:marginTop(10)
self.vwj2:marginLeft(20)
self.vwj1:children({self.vwj2})
self._view:addView(self.vwj1)
return self
end
function ui_class:updateData(uiSuper)
self=__module.weakSelf(self)
self.vwj2:text(model.title.__get)
if self._autoWatch then
self:addObserverId(model.title.__watchValueAll(function(new)
self.vwj2:text(new)
end
))
end
self.vwj1:onClick(function ()
model.title="lua中修改了title"
end)
end
local kvar1=ui(window)
kvar1:update(nil, window)
