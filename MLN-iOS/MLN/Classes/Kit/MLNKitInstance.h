//
//  MLNInstance.h
//  MLN
//
//  Created by MoMo on 2019/8/3.
//

#import <Foundation/Foundation.h>
#import "MLNConvertorProtocol.h"
#import "MLNExporterProtocol.h"
#import "MLNBeforeWaitingTaskProtocol.h"
#import "MLNViewControllerProtocol.h"
#import "MLNKitInstanceDelegate.h"
#import "MLNEntityExportProtocol.h"
#import "MLNKitLuaCoeBuilderProtocol.h"

typedef void (^MLNOnDestroyCallback)(void);

NS_ASSUME_NONNULL_BEGIN
@class MLNLuaCore;
@class MLNWindow;
@class MLNLuaTable;
@class MLNLuaBundle;
@class MLNExporter;
@class MLNLayoutContainerNode;
@class MLNLayoutEngine;
@class MLNKitInstanceHandlersManager;
@class MLNKitInstanceConsts;
/**
 承载Kit库bridge和LuaCore的实例，用来运行Lua文件。
 */
@interface MLNKitInstance : NSObject <NSKeyedArchiverDelegate> 

/**
 Lua 内核，每一个Instance都对应一个Lua 内核。
 */
@property (nonatomic, strong, readonly) MLNLuaCore *luaCore;

/**
Lua中的根视图。
*/
@property (nonatomic, strong, readonly) MLNWindow *luaWindow;

/**
 LuaWindowd所在的视图控制器
 */
@property (nonatomic, weak, readonly) UIViewController<MLNViewControllerProtocol> *viewController;

/**
 承载LuaWindow的根视图
 */
@property (nonatomic, weak, readonly) UIView *rootView;

/**
 当前执行模块的入口文件，相对LuaBundle的路径
 */
@property (nonatomic, copy, readonly) NSString *entryFilePath;

/**
 代理对象
 */
@property (nonatomic, weak) id<MLNKitInstanceDelegate> delegate;

/**
 原生类的注册导出工具
 */
@property (nonatomic, strong, readonly) id<MLNExporterProtocol> exporter;

/**
 Lua 与Native的类型转换工具
 */
@property (nonatomic, strong, readonly) id<MLNConvertorProtocol> convertor;

/**
 当前lua core运行的lua bundle环境。
 */
@property (nonatomic, strong, readonly) MLNLuaBundle *currentBundle;

/**
 布局引擎
 */
@property (nonatomic, strong, readonly) MLNLayoutEngine *layoutEngine;

/**
 其他处理句柄的管理器
 */
@property (nonatomic, strong, readonly) MLNKitInstanceHandlersManager *instanceHandlersManager;

/**
 记录对应Instance中通用信息配置
 */
@property (nonatomic, strong, readonly) MLNKitInstanceConsts *instanceConsts;

/**
 初始化方法, 默认运行的Lua bundle环境为Main Bundle.
 
 @param luaCoreBuilder LuaCore构建器
 @param viewController LuaWindow所在的视图控制器，并使用viewController.view作为承载LuaWindow的根视图
 @return Lua Core 实例
 */
- (instancetype)initWithLuaCoreBuilder:(id<MLNKitLuaCoeBuilderProtocol>)luaCoreBuilder viewController:(UIViewController<MLNViewControllerProtocol> *)viewController;

/**
 初始化方法
 
 @param luaBundlePath Lua core运行的Lua bundle环境，为空时默认为Main Bundle
 @param luaCoreBuilder LuaCore构建器
 @param viewController LuaWindow所在的视图控制器，并使用viewController.view作为承载LuaWindow的根视图
 @return LuaInstance实例
 */
- (instancetype)initWithLuaBundlePath:(NSString *__nullable)luaBundlePath luaCoreBuilder:(id<MLNKitLuaCoeBuilderProtocol>)luaCoreBuilder viewController:(UIViewController<MLNViewControllerProtocol> *)viewController;

/**
 初始化方法
 
 @param luaBundle Lua Core运行的Lua bundle环境, 为空时默认为Main Bundle
 @param luaCoreBuilder LuaCore构建器
 @param viewController LuaWindow所在的视图控制器，并使用viewController.view作为承载LuaWindow的根视图
 @return Lua Core 实例
 */
- (instancetype)initWithLuaBundle:(MLNLuaBundle *__nullable)luaBundle luaCoreBuilder:(id<MLNKitLuaCoeBuilderProtocol>)luaCoreBuilder viewController:(UIViewController<MLNViewControllerProtocol> *)viewController;

/**
 默认的初始化方法
 
 @param luaBundle Lua Core运行的Lua bundle环境，为空时默认为Main Bundle
 @param luaCoreBuilder LuaCore构建器
 @return Lua Core 实例
 @param rootView 承载LuaWindow的根视图
 @param viewController LuaWindowd所在的视图控制器
 @return LuaInstance实例
 */
- (instancetype)initWithLuaBundle:(MLNLuaBundle *__nullable)luaBundle luaCoreBuilder:(id<MLNKitLuaCoeBuilderProtocol>)luaCoreBuilder rootView:(UIView * __nullable)rootView viewController:(UIViewController<MLNViewControllerProtocol> *)viewController NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE; 

/**
 加载并执行数据

 @param entryFilePath 当前执行模块的入口文件
 @param windowExtra 传递给LuaWindow的参数，用来给页面传参
 @param error 错误信息
 @return 加载并执行是否成功
 */
- (BOOL)runWithEntryFile:(NSString *)entryFilePath windowExtra:(NSDictionary * __nullable)windowExtra error:(NSError ** __nullable)error;

/**
 重新加载执行

 @param error 错误信息
 @return 加载并执行是否成功
 */
- (BOOL)reload:(NSError ** __nullable)error;

/**
 重新加载执行

 @param entryFilePath 当前执行模块的入口文件
 @param windowExtra 传递给LuaWindow的参数，用来给页面传参
 @param error 错误信息
 @return 加载并执行是否成功
 */
- (BOOL)reloadWithEntryFile:(NSString *)entryFilePath windowExtra:(NSDictionary * __nullable)windowExtra error:(NSError ** __nullable)error;

/**
 注册类到状态机
 
 @param clazz 要被注册的可导出类
 @param error 错误信息
 @return 导出是否成功
 */
- (BOOL)registerClazz:(Class<MLNExportProtocol>)clazz error:(NSError ** __nullable)error;

/**
 注册类到状态机
 
 @param classes 要被注册的可导出类
 @param error 错误信息
 @return 导出是否成功
 */
- (BOOL)registerClasses:(NSArray<Class<MLNExportProtocol>> *)classes error:(NSError ** __nullable)error;

/**
 变更lua bundle环境
 
 @param bundlePath lua bundle的全路径
 */
- (void)changeLuaBundleWithPath:(NSString *)bundlePath;

/**
 变更lua bundle环境
 
 @param bundle 新的lua bundle
 */
- (void)changeLuaBundle:(MLNLuaBundle *)bundle;

/**
 变更承载LuaWindow的根视图
 
 @param rootView 承载LuaWindow的根视图
 */
- (void)changeRootView:(UIView *)rootView;

/**
 强引用对象
 
 @param objIndex 被强引用的对象在栈上的索引
 @param key 关联的key
 */
- (void)setStrongObjectWithIndex:(int)objIndex key:(NSString *)key;

/**
 强引用对象
 
 @param objIndex 被强引用的对象在栈上的索引
 @param cKey 关联的key
 */
- (void)setStrongObjectWithIndex:(int)objIndex cKey:(void *)cKey;

/**
 强引用对象
 
 @param obj 被强引用的对象
 @param key 关联的key
 */
- (void)setStrongObject:(id<MLNEntityExportProtocol>)obj key:(NSString *)key;

/**
 强引用对象

 @param obj 被强引用的对象
 @param cKey 关联的key
 */
- (void)setStrongObject:(id<MLNEntityExportProtocol>)obj cKey:(void *)cKey;

/**
 移除强引用对象
 
 @param key 关联的key
 */
- (void)removeStrongObject:(NSString *)key;

/**
 移除强引用对象

 @param cKey 关联的key
 */
- (void)removeStrongObjectForCKey:(void *)cKey;

/**
 添加监听Instance释放的回调

 @param callback 回调
 */
- (void)addOnDestroyCallback:(MLNOnDestroyCallback)callback;

/**
 移除监听Instance释放的回调
 
 @param callback 回调
 */
- (void)removeOnDestroyCallback:(MLNOnDestroyCallback)callback;

@end

@interface MLNKitInstance (LuaWindow)

/**
 标记并通知LuaWindow已经展示
 */
- (void)doLuaWindowDidAppear;

/**
 标记并通知LuaWindow已经消失
 */
- (void)doLuaWindowDidDisappear;

/**
 手动变更修改LuaWindow的大小

 @param newSize 新的大小
 */
- (void)changeLuaWindowSize:(CGSize)newSize;

@end

/**
 很多场景下，如果你要做的一些操作，需要依赖于MLN布局之后，请使用以下方法
 */
@interface MLNKitInstance (Layout)

/**
 添加布局的根节点

 @param rootnode 自动布局的根节点
 */
- (void)addRootnode:(MLNLayoutContainerNode *)rootnode;

/**
 移除布局的根节点

 @param rootnode 自动布局的根节点
 */
- (void)removeRootNode:(MLNLayoutContainerNode *)rootnode;

/**
 同步请求布局，立即执行一次布局
 */
- (void)requestLayout;

@end

/**
 很多场景下，如果你要做的一些操作，需要依赖于MLN布局之后，请使用以下方法
 */
@interface MLNKitInstance (LazyTask)

/**
 压栈自动布局完成以后执行的任务

 @param lazyTask 延迟执行任务
 */
- (void)pushLazyTask:(id<MLNBeforeWaitingTaskProtocol>)lazyTask;

/**
 出栈自动布局完成以后执行的任务

 @param lazyTask 延迟执行任务
 */
- (void)popLazyTask:(id<MLNBeforeWaitingTaskProtocol>)lazyTask;

/**
 压栈自动布局完成以后执行的动画任务，时机晚于LazyTask

 @param animation 动画任务，时机晚于LazyTask
 */
- (void)pushAnimation:(id<MLNBeforeWaitingTaskProtocol>)animation;

/**
 出栈自动布局完成以后执行的动画任务，时机晚于LazyTask

 @param animation 动画任务，时机晚于LazyTask
 */
- (void)popAnimation:(id<MLNBeforeWaitingTaskProtocol>)animation;

/**
 压栈自动布局完成以后执行的渲染任务，时机晚于动画任务

 @param renderTask 渲染任务，时机晚于动画任务
 */
- (void)pushRenderTask:(id<MLNBeforeWaitingTaskProtocol>)renderTask;

/**
 出栈自动布局完成以后执行的渲染任务，时机晚于动画任务

 @param renderTask 渲染任务，时机晚于动画任务
 */
- (void)popRenderTask:(id<MLNBeforeWaitingTaskProtocol>)renderTask;

@end

@interface MLNKitInstance (GC)

/**
 手动执行一次GC
 */
- (void)doGC;

@end

NS_ASSUME_NONNULL_END
