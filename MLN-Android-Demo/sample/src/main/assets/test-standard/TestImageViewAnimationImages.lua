
local screen_w = window:width()
local screen_h = window:height()

local scrollV = ScrollView()
scrollV:frame(Rect(0, 0, screen_w, screen_h))
scrollV:contentSize(Size(screen_w, screen_h * 1.5))
window:addView(scrollV)

local imageUrl = "https://thecodeway.com/blog/wp-content/uploads/2014/08/Lenna.png"
local imageUrl_placeholder = "https://thecodeway.com/blog/wp-content/uploads/2014/08/jpeg_15.jpg"


-- 示例：startAnimationImages
local imgV6 = ImageView()
imgV6:frame(Rect(20, 60, 200, 120))
imgV6:contentMode(ContentMode.SCALE_ASPECT_FILL)
imgV6:bgColor(Color(21, 122, 11, 1.0))


local imgs = { "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1159386606,974071300&fm=200&gp=0.jpg",
               "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1135295638,3697638664&fm=200&gp=0.jpg",
               "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1640210176,316780632&fm=27&gp=0.jpg",
               "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=729382916,2146689896&fm=27&gp=0.jpg" }



imgV6:startAnimationImages(imgs, 5, true)
scrollV:addView(imgV6)


local label6 = Label()
label6:text("startAnimationImages")
label6:textColor(Color(124, 45, 10, 1.0))
label6:frame(Rect(180, 80, 200, 30))


scrollV:addView(label6)