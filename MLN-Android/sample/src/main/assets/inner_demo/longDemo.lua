local label = Label():width(MeasurementType.MATCH_PARENT)
                     :height(MeasurementType.MATCH_PARENT)
                     :textAlign(TextAlign.CENTER)
                     :lines(10)
window:addView(label)

local float32 = 0x7fffff
local float64 = 0xfffffffffffff

local int32 = 0x7ffffffe
local int64 = 0x7ffffffffffffffe

local msg = {"float 32:"..tostring(float32),
"add 1:"..tostring(float32 + 1),
"float 64:"..tostring(float64),
"add 1:"..tostring(float64 + 1),
"int 32:"..tostring(int32),
"add 1:"..tostring(int32 + 1),
"int 64:"..tostring(int64),
"add 1:"..tostring(int64 + 1)
}

local str = table.concat(msg, '\n')
label:text(str)