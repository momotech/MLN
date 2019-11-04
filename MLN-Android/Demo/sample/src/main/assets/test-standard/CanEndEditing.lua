editView = EditTextView()

editView:canEndEditing(false)

editView:singleLine(true)
editView:placeholder("愿我们之间有故事~")
editView:marginLeft(10):marginRight(10):width(150):height(37)
editView:bgColor(Color():clear())
editView:fontSize(14)
editView:returnMode(ReturnType.Done)

value = editView:placeholder()



window:addView(editView)

window:onClick(function()
        Toast(tostring(value))
end)