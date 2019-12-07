

-- 示例：常规取消确认提示
local label1 = Label()
label1:text("常规取消确认提示")
label1:frame(Rect(20, 100, 200, 33))
label1:bgColor(Color(121, 121, 121, 1.0))
window:addView(label1)
label1:onClick(function()
    local alert = Alert()
    alert:title("我是标题")
    alert:message("我是消息啦！！")

    alert:setCancel("取消按钮", function()
        print("点击了取消按钮！")
    end)

    alert:setOk("ok按钮", function()
        print("点击啦OK按钮")
    end)

    alert:show()
end)

-- 示例：竖排多按钮
local label2 = Label()
label2:text("竖排多按钮")
label2:frame(Rect(20, 150, 200, 33))
label2:bgColor(Color(121, 121, 121, 1.0))
window:addView(label2)
label2:onClick(function()
    local alert = Alert()
    alert:title("我是标题")
    alert:message("我是消息啦！！")

    local btns = Array()
    btns:add("按钮1")
    btns:add("按钮2")
    btns:add("按钮3")
    btns:add("按钮4")
    btns:add("按钮5")
    alert:setButtonList(btns, function(number)
        print("点击了按钮", btns:get(number))
    end)

    alert:show()
end)

-- 示例：单个按钮文案和回调
local label3 = Label()
label3:text("单个按钮文案和回调")
label3:frame(Rect(20, 200, 200, 33))
label3:bgColor(Color(121, 121, 121, 1.0))
window:addView(label3)

label3:onClick(function()
    local alert = Alert()
    alert:title("我是标题")
    alert:message("我是消息啦！！")

    alert:setSingleButton("就我啦", function()
        print("点击了就我啦按钮")
    end)

    alert:show()


end)


-- 示例：测试dismiss
local label4 = Label()
label4:text("dismiss，自己消失")
label4:frame(Rect(20, 240, 200, 33))
label4:bgColor(Color(121, 121, 121, 1.0))
window:addView(label4)
label4:onClick(function()
    local alert = Alert()
    alert:title("我是标题")
    alert:message("等会我就消失")

    alert:setSingleButton("就我啦", function()
        print("点击了就我啦按钮")
    end)

    alert:show()

    System:setTimeOut(function()
        alert:dismiss()
    end,3)

end)

