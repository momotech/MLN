


local label4 = Label()
label4:y(50)
label4:width(100)
label4:height(100)
label4:fontSize(16)
label4:text("mapmapmapmapmap")
label4:bgColor(Color():hex(0xffff00):alpha(1))





label4:onClick(function()
    dialog = Dialog()

    local contentView2 = View():width(50):height(50)

    contentView2:bgColor(Color(255,0,0,1.0))
    --contentView2:bgColor(dialog)

    contentView2:setGravity(MBit:bor(Gravity.BOTTOM,Gravity.CENTER_HORIZONTAL))

    dialog:setContentGravity(MBit:bor(Gravity.TOP,Gravity.CENTER_HORIZONTAL))

    dialog:setContent(contentView2)
    dialog:show()
end)

window:addView(label4)