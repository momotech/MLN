local url = "http://cdnst.momocdn.com/w/u/others/2018/11/21/1542793204551-sing_loading_repeat.svga"

local svgaPlayer = nil

local btn = Label():text("reload"):x(10):y(20):width(80):height(60):bgColor(Color(123, 123, 0, 1))
btn:onClick(function()

    if svgaPlayer then
        svgaPlayer:removeFromSuper()
        svgaPlayer = SVGAPlayer():setGravity(Gravity.CENTER):width(300):height(300):bgColor(Color(23, 23, 23, 1))
    else
        svgaPlayer = SVGAPlayer():setGravity(Gravity.CENTER):width(300):height(300):bgColor(Color(23, 23, 23, 1))
    end
    svgaPlayer:fillMode(FillMode.Forward)
    svgaPlayer:setPauseCallback(function()
        print("keye", "setPauseCallback")
    end)
    svgaPlayer:setFinishedCallback(function()
        print("keye", "setFinishedCallback")
    end)

    window:addView(svgaPlayer)
    local sVGAParser = SVGAParser()
    sVGAParser:parse(url, function(svgaEntity)
        print("keye", "parse success")
        svgaPlayer:setImageDrawable(svgaEntity)
        svgaPlayer:startAnimation()
        print("keye", "startAnimation")
    end)

    print("keye", "click")
end)
window:addView(btn)