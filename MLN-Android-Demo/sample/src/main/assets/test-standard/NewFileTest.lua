local label4 = Label()
--label4:width(100)
label4:height(100)
label4:fontSize(16)
label4:text("mapmapmapmapmap")
label4:bgColor(Color():hex(0xffff00):alpha(1))
label4:onClick(function ()
    File:syncWriteFile('file://test/filetest_str.txt','write string')
    local readStrResult = File:syncReadString('file://test/filetest_str.txt')
    print('syncReadString result:'..readStrResult)

    local m = Map()
    m:put('key', 'value')
    File:syncWriteMap('file://test/filetest_map.txt',m)

    local array = Array()
    array:add('item1')
    array:add('item2')
    File:syncWriteArray('file://test/filetest_list.txt',array)

    File:asyncUnzipFile('file://test/1.zip','file://test/unzip',function (code,sourcePath)
        print("asyncUnzipFile code:"..code..' sourcePath:'..sourcePath)
    end)

    local syncUnzipResult = File:syncUnzipFile('file://test/2.zip','file://test/unzip');
    print('syncUnzipFile code:'..syncUnzipResult)

end)
local labelParent = View()
labelParent:y(50)
labelParent:x(50)
labelParent:setCornerRadiusWithDirection(8, MBit:bor(RectCorner.TOP_LEFT, RectCorner.TOP_RIGHT))
labelParent:bgColor(Color():hex(0xff00ff):alpha(1))
---labelParent:addView(label4)

window:addView(labelParent)
window:bgColor(Color():hex(0x00ff00):alpha(1))
local point = Point()
point:x(120)
point:y(120)
local convertToResult = labelParent:convertPointTo(label4,point)
print('convertPointTo point X:'..convertToResult:x())
print('convertPointTo point Y:'..convertToResult:y())

local convertFromResult = labelParent:convertPointFrom(window,point)
print('convertPointFrom point X:'..convertFromResult:x())
print('convertPointFrom point Y:'..convertFromResult:y())

local color = Color();
color:setColor("#a40044")
color:setColor("#02234545")
color:setColor('rgb(56,56,57)')
color:setColor('rgba(66,67,68,0.1)')

--labelParent:padding(0,9,0,9)
labelParent:addView(label4)


local styleString = StyleString('AAAAAA')
styleString:fontSize(30)
styleString:fontName("sans-serif-smallcaps")
styleString:setFontNameForRange("sans-serif-condensed-light", 1, 1)
styleString:setFontNameForRange("monospace", 2, 1)
styleString:setFontNameForRange("casual", 3, 1)
styleString:setFontNameForRange("sans-serif-medium", 4, 1)
styleString:setFontNameForRange("sans-serif-smallcaps", 5, 1)
label4:padding(20,80,20,80)
label4:styleText(styleString)

local imageView = ImageView()
imageView:frame(Rect(90, 130, 90, 90))
imageView:image("ic_launcher")
window:addView(imageView)

--label4:getCSS():height(50):paddingLeft(9):paddingRight(9):position(CSSPosition.ABSOLUTE)

--labelParent:getCSS():position(CSSPosition.ABSOLUTE)
--labelParent:flexChild(label4)
