# MLN
MLN是一个移动跨平台开发框架，让开发者用一套代码构建Android、iOS应用。MLN设计思路贴近原生开发，客户端开发者的经验，可以迅速迁移到MLN上，轻易构建出跨平台移动应用。

* 易上手，MLN专为客户端开发者设计，iOS、Android程序员非常容易上手。使用MLN不需要学习Node.js、npm、vue、ES6这些对客户端开发陌生的前端技术，也不强迫使用响应式框架。花几个小时了解下lua语言和文档就能轻松上手，客户端开发者的整个技术栈在这里都派得上用场。

* 占用包体积极小，1M左右。

* 真正的原生性能。跨平台往往意味着性能受损，得益于lua虚拟机的高性能和MLN优化，我们极大减少了中间介质影响，即使在低端安卓手机加载页面也极快。

## Demo运行
1. 获取库文件  
```
git clone https://github.com/momotech/MLN
``` 

2. 目录结构介绍  

| 序号 | 目录 | 功能描述 |
| ------------- | ------------ | ------------ |
| 1. | **MLN-Android** | Android SDK |
| 2. | **MLN-Android-Demo** | Android Demo |
| 3. | **MLN-iOS/Example** | iOS Demo |
| 4. | **MLN-iOS/MLN** | iOS SDK Core |
| 5. | **MLN-iOS/MLNDevTool** | iOS Develop Tool |
3. 使用Xcode或者Android Studio，打开示例工程
4. 运行效果如图所示  

<p>
    <img src="https://s.momocdn.com/w/u/others/custom/LuaNative/readme1.png" width="200"/>
	<p>iOS</p>
</p>
<p>
    <img src="https://s.momocdn.com/w/u/others/custom/LuaNative/readme2.png" width="200"/>
	<p>Android</p>
</p>

## 开发环境搭建
MLN推荐使用IDEA进行开发，IDEA安装插件后可以使用热重载方式进行页面预览
[配置指南](https://github.com/momotech/MLN/wiki/MLN%E5%BC%80%E5%8F%91%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BA)

## SDK接入
* [iOS](https://github.com/momotech/MLN/wiki/sdk%E6%8E%A5%E5%85%A5)
* [Android](https://github.com/momotech/MLN/wiki/sdk%E6%8E%A5%E5%85%A5)

## IDE插件、Demo和开发工具
[IDEA](http://www.jetbrains.com/idea/download/#section=mac)
[IDEA热重载插件](https://s.momocdn.com/w/u/others/custom/LuaNative/MomoLuaNative.zip)

## 开发体验
MLN支持热重载开发方式，修改代码，立即生效，免去编译等待阶段
![热重载.gif](https://s.momocdn.com/w/u/others/custom/LuaNative/readme3.gif)

## 如何交流

目前推荐通过issue交流问题

## 贡献代码

[贡献指南，整理上传中。。。]()
