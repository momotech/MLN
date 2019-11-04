# Momo Lua SDK

Momo Lua SDK是一套跨平台解决方案，开发者使用Lua语言可一次性开发出在Android和iOS中运行的应用，并支持动态更新。

---

## 接入方法

gradle中配置方法：

```
implementation "com.immomo.mlncore:core:$mlnCoreVersion"
implementation "com.immomo.mls:mln:$mlnsVersion"
debugImplementation "com.immomo.luanative:hotreload:$hotreloadVersion"
releaseImplementation "com.immomo.luanative:hotreload_empty:$hotreloadVersion"
annotationProcessor "com.immomo.mls:processor:$processorVersion"
```

在application初始化时初始化Lua Engine：

```
LVConifg config = new LVConfigBuilder(context)
                .setRootDir(rootDir)                  //设置lua根目录
                .setImageDir(imageDir)            //设置lua图片根目录
                .setCacheDir(cacheDir)            //设置lua缓存目录
                .build();
//MLSEngine已注册通用view和工具
MLSEngine.init(context, debugable)
    .setLVConfig(config)
    .setImageProvider(imageProvider)                        //lua加载图片工具，不实现的话，图片无法展示
    .setGlobalEventAdapter(globalEventImpl)                 //全局事件，lua与native交互，若不使用全局事件，可不实现
    .setLoadViewAdapter(loadViewAdapter)                    //生成lua列表加载更多的view，有默认实现，但UI样式可能不是应用需要的
    .setUncatchExceptionListener(uncatchExceptionLisener)   //设置lua环境异常监听，建议设置，并在回调中返回true，将lua中的异常全部catch住
    .registerUD(Holder.UDHolder[])                          //注册lua中的类，若没有可删除
    .registerSC(Holder.SHolder[])                           //注册lua中静态工具类，若没有可删除
    .registerConstants(Class[])                             //注册lua中枚举，若没有可删除
    .build();
```

在Activity、Fragment或任意View中显示LuaView：

```
MLSInstance instance = new MLSInstance(context);
instance.setContainer(frameLayout);
InitData initData = new InitData(luaUrl); //MLSBundleUtils.parseFromBundle(bundle); MLSBundleUtils.createBundle(url)
instance.setData(initData);
if (!instance.isValid()) {
      //非法url处理，比如finishActivity等
}

// instance三个生命周期记得调用:
instance.onResume();
instance.onPause();
instance.onDestroy();
```

---

## 为Lua增加接口调用

Lua中可以有3种方式调用接口

- 先生成一个对象并调用其中方法
- 不用生成对象，直接调用类方法
- 使用枚举

## 使用方法

#### 加载脚本、执行脚本：
```
Globals globals = Globals.createLState(debugable); //创建Lua虚拟机
globals.registerStaticBridgeSimple("LuaBridgeName", JavaClass.class, ...); //注册Java静态方法
globals.registerUserdataSimple("LuaBridgeName2", JavaClass2.class, ...); //注册Java对象，并生成userdata

boolean result = globals.loadString("name", str);//加载lua源码
boolean result = globals.loadData("name", data); //加载lua源码或二进制码
/// 二进制码必须在相同的机器环境下编译
// globals.compileAndSave(file, luaData);//将Lua源码编译成二进制码，并保存到file中

if (result)
    result = globals.callLoadedData();//执行刚加载成功的lua脚本
```

#### 静态Bridge编写
```
@LuaApiUsed //增加这个注释，并保证此类不会被混淆
class StaticBridge {
    /// 方法参数必须为long, LuaValue[]类型
    /// 返回值类型必须为LuaValue[]
    @LuaApiUsed
    static LuaValue[] bridgeA(long L, LuaValue[] p) {
        // code
        return null;//可返回空
    }
}
```

#### Userdata编写

继承`LuaUserdata`，根据暴露接口编写；若需要Java层管理内存，则继承`JavaUserdata`，且在使用完成后，调用`destroy`方法
```
@LuaApiUsed
class MyUserdata extends LuaUserdata {
    @LuaApiUsed
    MyUserdata(long L, LuaValue[] v) {
        super(L, v);
    }

    /// 方法参数和返回值类型必须为LuaValue[]
    @LuaApiUsed
    LuaValue[] bridgeA(LuaValue[] p) {
        // code
        return null; // 可返回空
    }
}

globals.registerUserdataSimple("MyUserdataName", MyUserdata.class, "bridgeA"); //注册userdata
```

java code
```
/// Size.java
/// 标记此类为非静态(userdata)类型，且内存由lua控制
/// 将会生成 继承 LuaUserdata(内存由lua控制) 的 Size_udwrapper 类
@LuaClass(isStatic = false, gcByLua = true)
public class Size {
    /// 必须有此构造方法
    public Size(Globals g, LuaValue[] init) {}

    public Size(double w, double h) {
        this.width = w;
        this.height = h;
    }
    /// 标记此属性可被lua通过 w方法调用
    /// 若方法中不传参数，则表示getter方法，若传参数，则表示setter方法
    @LuaBridge(alias = "w")
    double width;
    @LuaBridge(alias = "h")
    double height;

    /// 标记此方法可被lua通过 area方法调用
    @LuaBridge
    public double area() {
        return width * height;
    }

    public boolean equals(Object other) {
        if (this == other) return true;
        if (other == null) return false;
        if (getClass() != other.getClass()) return false;
        Size os = (Size)other;
        return os.width == width && os.height == height;
    }
}

/// AreaUtils.java
/// 标记此类为静态(table)类型
/// 将会生成 AreaUtils_sbwrapper 类
@LuaClass(isStatic = true)
public class AreaUtils {
    /// 标记此方法可被lua通过 newSize方法调用
    /// 并返回给lua一个userdata(Size)
    @LuaBridge
    static Size newSize(double w, double h) {
        return new Size(w, h);
    }

    /// 标记此方法可被lua通过 calSizeArea方法调用
    @LuaBridge(alias = "calSizeArea")
    static double csa(Size s) {
        return s.area();
    }
}

/// 初始化，如Application中
/// 提前注册userdata相关信息
Register.registerUserdata(Size.class, lazyLoad, "Size");
/// 提前注册静态接口相关信息
Register.registerStaticBridge("AreaUtils", AreaUtils.class);
/// 虚拟机创建后，将缓存的注册信息安装到相应lua环境中
Register.install(globals);

/// 自动类型转换机制，若未调用下面方法，则AreaUtils两个方法均不可用
/// 自动将Lua数据类型userdata(Size)转换成java数据类型Size
UserdataTranslator.registerL2JAuto(Size.class);
/// 自动将java数据类型Size转换成lua数据类型userdata(Size)
UserdataTranslator.registerJ2LAuto(Size.class);
```


#### 混淆注意
```
-keep class com.xfy.luajava.utils.LuaApiUsed
-keep @com.xfy.luajava.utils.LuaApiUsed class * {
    native <methods>;
    @com.xfy.luajava.utils.LuaApiUsed <methods>;
    @com.xfy.luajava.utils.LuaApiUsed <fields>;
}
```