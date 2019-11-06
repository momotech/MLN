imageUrl = "https://thecodeway.com/blog/wp-content/uploads/2014/08/Lenna.png"
imageUrl_placeholder = "https://thecodeway.com/blog/wp-content/uploads/2014/08/jpeg_15.jpg"

local imgV2 = ImageView()
local imgV3 = ImageView()

 imgV2:setCornerImage(imageUrl, imageUrl_placeholder, 20)
 imgV3:setCornerImage(imageUrl, imageUrl_placeholder, 30, RectCorner.TOP_LEFT)

local screen_w = window:width()
local screen_h = window:height()

local scrollV = ScrollView()
scrollV:frame(Rect(0, 0, screen_w, screen_h))
scrollV:contentSize(Size(screen_w, screen_h * 1.5))
window:addView(scrollV)



-- 示例：SCALE_TO_FILL
local imgV2 = ImageView()
imgV2:frame(Rect(20, 230, 200, 120))
imgV2:contentMode(ContentMode.SCALE_TO_FILL)

 imgV2:setCornerImage(imageUrl, imageUrl_placeholder, 20)


imgV2:setCornerImage(nil, nil, 20)



imgV2:bgColor(Color(21, 122, 11, 1.0))
-- imgV2:padding(5, 5, 5, 5)
scrollV:addView(imgV2)
local label2 = Label()
label2:frame(Rect(180, 260, 200, 30))
label2:text("SCALE_TO_FILL")
label2:textColor(Color(124, 45, 10, 1.0))
scrollV:addView(label2)

-- 示例：SCALE_ASPECT_FIT
local imgV3 = ImageView()
imgV3:frame(Rect(20, 360, 200, 120))
imgV3:contentMode(ContentMode.SCALE_ASPECT_FIT)

 imgV3:setCornerImage(imageUrl, "", 30, RectCorner.TOP_LEFT)


imgV3:setCornerImage(nil, nil, 30, RectCorner.TOP_LEFT)




imgV3:bgColor(Color(21, 122, 11, 1.0))
-- imgV3:padding(5, 5, 5, 5)
scrollV:addView(imgV3)
local label3 = Label()
label3:text("SCALE_ASPECT_FIT")
label3:textColor(Color(124, 45, 10, 1.0))
label3:frame(Rect(180, 370, 200, 30))
scrollV:addView(label3)