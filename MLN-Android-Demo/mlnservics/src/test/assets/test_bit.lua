local start = os.clock()
print('start', start)
for i=1,1000 do
    MBit:bor(0x11, 0xff, 0xf01, 0xff000)
end

local endT = os.clock()
print('endT', endT)
print('cast', (endT-start))

print('band---', MBit:band(235, 0xff))