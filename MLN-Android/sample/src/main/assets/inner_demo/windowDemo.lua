
screen_w = window:width()
screen_h = window:height()
local stateBar = window:stateBarHeight()

local baseView = View()
baseView:width(100):height(100)
baseView:x(100):y(stateBar + 100)
baseView:bgColor(Color(255, 0, 0, 1))
baseView:cornerRadius(10)
baseView:borderWidth(10)
baseView:borderColor(Color(0, 255, 0, 1))
baseView:onClick(function ()
print('click')
end)

window:addView(baseView)

-- window生命周期方法调用
-- 1.sizeChanged 回调window的宽和高
window:sizeChanged(function(width,height)
    Toast("sizeChanged",2)
    print("window:sizeChanged")
end)

-- 2.viewAppear 视图渲染完成后回调
window:viewAppear(function()
    Toast("viewAppear",2)
    print("window:viewAppea")
end)

-- 3.viewDisappear 离开页面后调用，退出APP时正在展示的Lua会调用
window:viewDisappear(function()
    Toast("viewDisappear",2)
    print("window:viewDisappear")
end)

-- 4.onDestroy Lua页面销毁后调用
window:onDestroy(function()
    Toast("onDestroy",2)
    print("window:onDestroy")
end)

