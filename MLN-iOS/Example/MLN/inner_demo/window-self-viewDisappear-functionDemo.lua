
-- viewDisappear 离开页面后调用，退出APP时正在展示的Lua会调用
window:viewDisappear(function()
    Toast("viewDisappear",2)
    print("window:viewDisappear")
end)


