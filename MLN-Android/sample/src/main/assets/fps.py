# encoding: utf-8
import os
import time

os.system('adb shell dumpsys gfxinfo com.immomo.mln reset')
time.sleep(2)
os.system('adb shell dumpsys gfxinfo com.immomo.mln reset')
time.sleep(2)
for i in range(1,25):
   os.system("adb shell input swipe 567 1700 567 800")
   time.sleep(0.5)
   print "执行第",i,"次滑动"
time.sleep(1)
print "打印整体卡顿数据"
os.system('adb shell dumpsys gfxinfo com.immomo.mln')