简体中文 | [English](./README.en-US.md)
# MLN
MLN是一个移动跨平台开发框架，让开发者用一套代码构建Android、iOS应用。MLN设计思路贴近原生开发，客户端开发者的经验，可以迅速迁移到MLN上，轻易构建出跨平台移动应用。

* 专为客户端开发者设计。

* 增加包体积极小，1.2M。

* 真正的原生性能。跨平台往往意味着性能受损，得益于lua虚拟机的高性能和MLN优化，我们极大减少了中间介质影响，即使在低端安卓手机加载页面也极快。

* 支持热更新。  

## 开发环境搭建
  * IntelliJ IDEA：MLN推荐使用IDEA进行开发，IDEA安装插件后可以使用热重载方式进行页面预览
  [配置指南](https://github.com/momotech/MLN/wiki/MLN开发环境搭建)  
  * Android Studio(推荐使用3.5版本)：[下载地址](https://developer.android.com/studio/?gclid=EAIaIQobChMIoceaiI-q5gIVwWkqCh3nmAMREAAYASAAEgLoYfD_BwE)    
  * Xcode：可在App Store中搜索下载  

## Demo运行
通过Demo了解MLN，前往[Demo运行](https://github.com/momotech/MLN/wiki/Demo运行)

## SDK接入
* [Android](https://github.com/momotech/MLN/wiki/sdk接入#Android接入)
* [iOS](https://github.com/momotech/MLN/wiki/sdk接入#iOS接入)

## 新增Bridge 
* [Android](https://github.com/momotech/MLN/wiki/新增Bridge#Android原生Bridge编写)
* [iOS](https://github.com/momotech/MLN/wiki/新增Bridge#iOS原生Bridge编写)

## 开发体验
MLN支持热重载开发方式，修改代码，立即生效，免去编译等待阶段
![热重载.gif](https://s.momocdn.com/w/u/others/custom/LuaNative/readme3.gif)

## MLN在陌陌内部的应用
陌陌首页、直播帧、更多帧部分内容、附近群组、狼人圈等一系列功能都是用MLN开发的。MLN的稳定性和性能在一年多的时间里，经受住了陌陌过亿量级MAU的考验。
![](https://s.momocdn.com/w/u/others/2019/12/23/1577096701198-mln.png)
## 如何交流

我们正在把陌陌内部MLN社区迁移到github，不管是公司内部还是外部提出的issue，开发组都会做到高效支持。
工作时间内（陌陌早十晚七，没有996）收到有效issue：
+ 4小时内给出响应
+ 能够重现的问题，一工作日内给出解决时间点

Projects里有[MLN项目近期开发计划](https://github.com/momotech/MLN/projects/1)，如果你有更好的想法
请在issue里提建议，我们一起讨论下一步该做什么。

## 如何贡献代码

沟通邮箱：zhang.yupeng@immomo.com

