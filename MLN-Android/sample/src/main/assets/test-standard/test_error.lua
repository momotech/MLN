
BGColor = Color(255,0,0)
M = MeasurementType.MATCH_PARENT
W = MeasurementType.WRAP_CONTENT

local root = LinearLayout(LinearType.VERTICAL):width(M)
:height(M)

function createLabel(text, f)
    local b = Label():text(text):width(100):height(50):bgColor(BGColor)
    b:onClick(f)
    root:addView(b)
end

local function shortVersion(ver)
    ver = string.reverse(ver)
    local arr = {
        string.sub(ver, 10),
        string.sub(ver, 6, 9),
        string.sub(ver, 2, 5),
        string.sub(ver, 1, 1),
    }

    arr[2] = tostring(tonumber(string.reverse(arr[2])))
    arr[3] = tostring(tonumber(string.reverse(arr[3])))

    local newArr = { arr[1],".",arr[2],".",arr[3],".",arr[4] }
    return table.concat(newArr)
end
createLabel("require error", function()
    print(shortVersion("0"))
    --require('xxx')
end)

createLabel("nil invoke", function()
    print(shortVersion("预埋包"))
    --local v = nil
    --v.invoke()
end)

createLabel("特殊字符", function()
    --print(shortVersion("2000000061"))
    --print(shortVersion("0"))
    --print(shortVersion("预埋包"))
    print(shortVersion())
end)

window:addView(root)