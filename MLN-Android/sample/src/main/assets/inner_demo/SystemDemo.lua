
local width = window:width()
local height = window:height()

local color_Gray = Color(105, 105, 105, 1)
local contentView = View()
contentView:frame(Rect(0, 0, width, height))
contentView:bgColor(color_Gray)
window:addView(contentView)


local scrollView = ScrollView():height(height - 30):width(width):marginTop(60)
local showLabel = Label()--显示结果
showLabel:height(height - 30):lines(0):fontSize(20):textAlign(TextAlign.LEFT):textColor(Color(0, 0, 0, 1)):bgColor(Color(222, 222, 222, 1)):marginLeft(8):textColor(Color(0, 0, 0, 1))
showLabel:width(width - 16)
scrollView:addView(showLabel)
contentView:addView(scrollView)

local showText = ""

showText =  "OSVersion: " .. tostring(System:OSVersion())
showText =  showText .."\n" .."SDKVersion: " .. tostring(System:SDKVersion())
showText =  showText .."\n" .."SDKVersionInt: " .. tostring(System:SDKVersionInt())
showText =  showText .."\n" .."iOS: " .. tostring(System:iOS())
showText =  showText .."\n" .."Android: " .. tostring(System:Android())


showText =  showText .."\n\n" .."scale: " .. tostring(System:scale())
local screenSize = System:screenSize()
showText =  showText .."\n\n" ..string.format("screenSize: width = %d, height = %d", screenSize:width(), screenSize:height())
showText =  showText .."\n\n" .."navBarHeight: " .. tostring(System:navBarHeight())
showText =  showText .."\n\n" .."stateBarHeight: " .. tostring(System:stateBarHeight())
showText =  showText .."\n\n" .."homeIndicatorHeight: " .. tostring(System:homeIndicatorHeight())
showText =  showText .."\n\n" .."tabBarHeight: " .. tostring(System:tabBarHeight())
showText =  showText .."\n\n" .."deviceInfo: " .. tostring(System:deviceInfo())

showLabel:text(showText)

System:asyncDoInMain(function()
showText = showText .. "\n\n" .."asyncDoInMain: " .. "do someThing"
showLabel:text(showText)
end)

System:setTimeOut(function()
showText =  showText .."\n\n" .. "setTimeOut: delay 3s, callbacked"
showLabel:text(showText)
end, 3)


----以下代码不用管，显示UI用的
local btnInfo = { "showStatusBar", "hideStatusBar" }

local btnScrollView = ScrollView(true):height(50):width(width):padding(4, 0, 4, 0)
contentView:addView(btnScrollView)
local tabsContainer = LinearLayout(LinearType.HORIZONTAL):setWrapContent(true)
btnScrollView:addView(tabsContainer)

local tabs = {}
for i, v in ipairs(btnInfo) do
local start, last = string.find(v, "demo.")
local name
if last and last < #v then
name = string.sub(v, last + 1, #v)
else
name = v
end
local tab = Label():setWrapContent(true):textAlign(TextAlign.CENTER):setMinWidth(80):marginLeft(5):padding(0, 5, 5, 5):height(50):fontSize(14):text(name):bgColor(Color(211, 211, 211, 1)):textColor(Color(0, 0, 0, 1))
tabsContainer:addView(tab)
tabs[v] = tab
end

for i, v in pairs(tabs) do
if i == btnInfo[1] then
v:onClick(function()
System:showStatusBar()
end)
elseif i == btnInfo[2] then
v:onClick(function()
System:hideStatusBar()
end)
end
end
