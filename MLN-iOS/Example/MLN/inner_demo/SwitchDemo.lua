

switch = Switch()
switch:frame(Rect(100, 100, 100, 80))
switch:bgColor(Color(223, 213, 12, 1))

switch:setSwitchChangedCallback(function(isOn)
    print("switch changed -----", isOn)
    print("switch ----- ", switch:on())
end)

window:addView(switch)

