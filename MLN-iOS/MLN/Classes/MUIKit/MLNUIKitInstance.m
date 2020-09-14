//
//  MLNUIInstance.m
//  MLNUI
//
//  Created by MoMo on 2019/8/3.
//

#import "MLNUIKitInstance.h"
#import "MLNUILuaCore.h"
#import "MLNUILuaTable.h"
#import "MLNUILayoutEngine.h"
#import "MLNUIBeforeWaitingTaskEngine.h"
#import "MLNUIKiConvertor.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIKitInstanceHandlersManager.h"
#import "MLNUIWindow.h"
#import "MLNUIKitInstanceConsts.h"
#import "MLNUIFile.h"
#import "MLNUIKitBridgesManager.h"
#import "ArgoBindingConvertor.h"

#define kMLNUIRunLoopBeforeWaitingLazyTaskOrder   1
#define kMLNUIRunLoopBeforeWaitingRenderOrder     2
#define kMLNUIRunLoopBeforeWaitingAnimtaionOrder  3

@interface MLNUIKitInstance ()<MLNUIErrorHandlerProtocol, MLNUILuaCoreDelegate> {
    MLNUILuaCore *_luaCore;
    MLNUILayoutEngine *_layoutEngine;
    MLNUIWindow *_luaWindow;
}
@property (nonatomic, strong) id<MLNUIKitLuaCoeBuilderProtocol> luaCoreBuilder;
@property (nonatomic, strong) NSMutableArray<Class<MLNUIExportProtocol>> *innerRegisterClasses;
@property (nonatomic, strong) MLNUIBeforeWaitingTaskEngine *lazyTaskEngine;
@property (nonatomic, strong) MLNUIBeforeWaitingTaskEngine *animationEngine;
@property (nonatomic, strong) MLNUIBeforeWaitingTaskEngine *renderEngine;
@property (nonatomic, strong) NSMutableArray *onDestroyCallbacks;
@property (nonatomic, assign) BOOL didViewAppear;
@property (nonatomic, assign) BOOL needCallAppear;

@end

// Deprecated
@interface MLNUIKitInstance ()
@property (nonatomic) Class<MLNUIConvertorProtocol> convertorClass;
@property (nonatomic) Class<MLNUIExporterProtocol> exporterClass;
@property (nonatomic, strong) MLNUIKitBridgesManager *bridgesManager;

@end

@implementation MLNUIKitInstance (LuaWindow)

- (MLNUIWindow *)createLuaWindow
{
    return [[MLNUIWindow alloc] initWithMLNUILuaCore:self.luaCore frame:self.rootView.bounds];
}

- (void)setupLuaWindow:(NSMutableDictionary *)windowExtra
{
    PSTART_TAG(MLNUILoadTimeStatisticsType_Custom, @"other3");
    if (!self.luaWindow) {
        _luaWindow = [self createLuaWindow];
    }
    PEND_TAG_INFO(MLNUILoadTimeStatisticsType_Custom, @"other3", @"【其他初始化-create window】");

    self.luaWindow.extraInfo = windowExtra;
    [self.luaCore registerGlobalVar:self.luaWindow globalName:@"window" error:nil];
    self.luaWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.rootView addSubview:self.luaWindow];
}

- (void)pushWindowToLayoutEngine
{
    __unsafe_unretained MLNUILayoutNode *node = self.luaWindow.mlnui_layoutNode;
    node.width = MLNUIPointValue(self.rootView.bounds.size.width);
    node.height = MLNUIPointValue(self.rootView.bounds.size.height);
    [self.layoutEngine addRootnode:node];
}

- (void)doLuaWindowDidAppear
{
    self.didViewAppear = YES;
    if (self.luaWindow && [self.luaWindow canDoLuaViewDidAppear]) {
        [self.luaWindow doLuaViewDidAppear];
        self.needCallAppear = NO;
        return;
    }
    self.needCallAppear = YES;
}

- (void)redoLuaViewDidAppearIfNeed
{
    if (self.needCallAppear && self.didViewAppear) {
        [self.luaWindow doLuaViewDidAppear];
    }
}

- (void)doLuaWindowDidDisappear
{
    self.didViewAppear = NO;
    if (self.luaWindow && [self.luaWindow canDoLuaViewDidDisappear]) {
        [self.luaWindow doLuaViewDidDisappear];
    }
}

- (void)changeLuaWindowSize:(CGSize)newSize
{
    CGRect newFrame = self.luaWindow.frame;
    newFrame.size.width = newSize.width;
    newFrame.size.height = newSize.height;
    self.luaWindow.frame = newFrame;
}

@end

@implementation MLNUIKitInstance

#pragma mark - MLNUIErrorHandlerProtocol
- (BOOL)canHandleAssert:(MLNUILuaCore *)luaCore
{
    return [self.instanceHandlersManager.errorHandler canHandleAssert:self];
}

- (void)luaCore:(MLNUILuaCore *)luaCore error:(NSString *)error
{
    [self.instanceHandlersManager.errorHandler instance:self error:error];
}

- (void)luaCore:(MLNUILuaCore *)luaCore luaError:(NSString *)error luaTraceback:(NSString *)luaTraceback
{
    [self.instanceHandlersManager.errorHandler instance:self luaError:error luaTraceback:luaTraceback];
}

#pragma mark - MLNUILuaCoreDelegate
- (void)luaCore:(MLNUILuaCore *)luaCore willLoad:(NSData *)data filePath:(NSString *)filePath
{
    if ([self.delegate respondsToSelector:@selector(instance:willLoad:fileName:)]) {
        [self.delegate instance:self willLoad:data fileName:filePath];
    }
}

- (void)luaCore:(MLNUILuaCore *)luaCore didLoad:(NSData *)data filePath:(NSString *)filePath
{
    if ([self.delegate respondsToSelector:@selector(instance:didLoad:fileName:)]) {
        [self.delegate instance:self didLoad:data fileName:filePath];
    }
}

- (void)luaCore:(MLNUILuaCore *)luaCore didFailLoad:(NSData *)data filePath:(NSString *)filePath error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(instance:didFailLoad:fileName:error:)]) {
        [self.delegate instance:self didFailLoad:data fileName:filePath error:error];
    }
}

#pragma mark - Public For LuaCore
- (instancetype)initWithMLNUILuaCoreBuilder:(id<MLNUIKitLuaCoeBuilderProtocol>)luaCoreBuilder viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController
{
    return [self initWithLuaBundle:[MLNUILuaBundle mainBundle] luaCoreBuilder:luaCoreBuilder viewController:viewController];
}

- (instancetype)initWithLuaBundlePath:(NSString *__nullable)luaBundlePath luaCoreBuilder:(id<MLNUIKitLuaCoeBuilderProtocol>)luaCoreBuilder viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController
{
    return [self initWithLuaBundle:[MLNUILuaBundle mainBundleWithPath:luaBundlePath] luaCoreBuilder:luaCoreBuilder viewController:viewController];
}

- (instancetype)initWithLuaBundle:(MLNUILuaBundle *__nullable)luaBundle luaCoreBuilder:(id<MLNUIKitLuaCoeBuilderProtocol>)luaCoreBuilder viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController
{
    return [self initWithLuaBundle:luaBundle luaCoreBuilder:luaCoreBuilder rootView:nil viewController:viewController];
}

- (instancetype)initWithLuaBundle:(MLNUILuaBundle *__nullable)luaBundle luaCoreBuilder:(id<MLNUIKitLuaCoeBuilderProtocol>)luaCoreBuilder rootView:(UIView *)rootView viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController
{
    if (self = [super init]) {
        _currentBundle = luaBundle;
        _luaCoreBuilder = luaCoreBuilder;
        _rootView = rootView;
        _viewController = viewController;
        _instanceHandlersManager = [[MLNUIKitInstanceHandlersManager alloc] initWithUIInstance:self];
        _instanceConsts = [[MLNUIKitInstanceConsts alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self releaseAll];
}

- (BOOL)runWithEntryFile:(NSString *)entryFilePath windowExtra:(NSDictionary *)windowExtra error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    _windowExtra = [NSMutableDictionary dictionaryWithDictionary:windowExtra];
    _entryFilePath = entryFilePath;
    // 准备环境
    [self setup];
    // 执行
    return [self runWithEntryFile:entryFilePath error:error];
}

- (BOOL)runWithEntryFile:(NSString *)entryFilePath error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!stringNotEmpty(entryFilePath)) {
        if (error) {
            *error = [NSError mlnui_errorCall:@"entry file is nil!"];
        }
        MLNUIError(self.luaCore, @"entry file is nil!");
        if ([self.delegate respondsToSelector:@selector(instance:didFailRun:error:)]) {
            if (error) {
                [self.delegate instance:self didFailRun:entryFilePath error:*error];
            } else {
                [self.delegate instance:self didFailRun:entryFilePath error:nil];
            }
        }
        return NO;
    }
    
    // 执行
    NSError *err = nil;
    if ([self.luaCore runFile:entryFilePath error:&err]) {
        // 请求布局
        PSTART_TAG(MLNUILoadTimeStatisticsType_Custom,@"布局");
        [self forceLayoutLuaWindow];
        PEND_TAG_INFO(MLNUILoadTimeStatisticsType_Custom, @"布局", @"【布局】");
//        PEND_TAG_INFO(MLNUILoadTimeStatisticsType_Custom, @"布局", @"【布局】")
        // 回调代理
        if ([self.delegate respondsToSelector:@selector(instance:didFinishRun:)]) {
            [self.delegate instance:self didFinishRun:entryFilePath];
        }
        return YES;
    }
    if (error) {
        *error = err;
    }
    // 回调代理
    if ([self.delegate respondsToSelector:@selector(instance:didFailRun:error:)]) {
        [self.delegate instance:self didFailRun:entryFilePath error:err];
    }
    return NO;
}

- (BOOL)reload:(NSError * _Nullable __autoreleasing *)error
{
    return [self reloadWithEntryFile:_entryFilePath windowExtra:_windowExtra error:error];
}

- (BOOL)reloadWithEntryFile:(NSString *)entryFilePath windowExtra:(NSDictionary *)windowExtra error:(NSError * _Nullable __autoreleasing *)error
{
    MLNUIAssert(self.luaCore, (entryFilePath && entryFilePath.length >0), @"entry file is nil!");
    // 释放当前环境
    [self releaseAll];
    self.needCallAppear = YES;
    // 更新参数配置
    _windowExtra = [NSMutableDictionary dictionaryWithDictionary:windowExtra];
    _entryFilePath = entryFilePath;
    // 准备环境
    [self setup];
    // 注册bridge
    if (![self.luaCore registerClasses:_innerRegisterClasses error:error]) {
        return NO;
    }
    // 执行
    if ([self runWithEntryFile:entryFilePath error:error]) {
        [self redoLuaViewDidAppearIfNeed];
        return YES;
    }
    return NO;
    
}

- (BOOL)registerClazz:(Class<MLNUIExportProtocol>)clazz error:(NSError * _Nullable __autoreleasing *)error
{
    [self.innerRegisterClasses addObject:clazz];
    return [self.luaCore registerClazz:clazz error:error];
}

- (BOOL)registerClasses:(NSArray<Class<MLNUIExportProtocol>> *)classes error:(NSError * _Nullable __autoreleasing *)error
{
    [self.innerRegisterClasses addObjectsFromArray:classes];
    return [self.luaCore registerClasses:classes error:error];
}

- (void)changeLuaBundleWithPath:(NSString *)bundlePath
{
    _currentBundle = [[MLNUILuaBundle alloc] initWithBundlePath:bundlePath];
    [self.luaCore changeLuaBundle:_currentBundle];
}

- (void)changeLuaBundle:(MLNUILuaBundle *)bundle
{
    NSAssert(![[bundle bundlePath] hasSuffix:@"ArgoUISystem.bundle"], @"业务使用的bundle名字不能是ArgoUISystem.bundle");
    _currentBundle = bundle;
    [self.luaCore changeLuaBundle:bundle];
}

- (void)changeRootView:(UIView *)rootView
{
    _rootView = rootView;
    if (self.luaWindow) {
        [self.luaWindow removeFromSuperview];
        self.luaWindow.frame = rootView.bounds;
        [self.rootView addSubview:self.luaWindow];
    }
}

- (void)setStrongObjectWithIndex:(int)objIndex key:(NSString *)key
{
    [self.luaCore setStrongObjectWithIndex:objIndex key:key];
}

- (void)setStrongObjectWithIndex:(int)objIndex cKey:(void *)cKey
{
    [self.luaCore setStrongObjectWithIndex:objIndex cKey:cKey];
}

- (void)setStrongObject:(id<MLNUIEntityExportProtocol>)obj key:(NSString *)key
{
    [self.luaCore setStrongObject:obj key:key];
}

- (void)setStrongObject:(id<MLNUIEntityExportProtocol>)obj cKey:(nonnull void *)cKey
{
    [self.luaCore setStrongObject:obj cKey:cKey];
}

- (void)removeStrongObject:(NSString *)key
{
    [self.luaCore removeStrongObject:key];
}

- (void)removeStrongObjectForCKey:(void *)cKey
{
    [self.luaCore removeStrongObjectForCKey:cKey];
}

- (void)addOnDestroyCallback:(MLNUIOnDestroyCallback)callback
{
    if (!callback || [_onDestroyCallbacks containsObject:callback]) {
        return;
    }
    [self.onDestroyCallbacks addObject:callback];
}

- (void)removeOnDestroyCallback:(MLNUIOnDestroyCallback)callback
{
    if (callback) {
        [_onDestroyCallbacks removeObject:callback];
    }
}

- (void)doOnDestroyCallbacks
{
    NSArray *destroyCallbacks = _onDestroyCallbacks.copy;
    for (MLNUIOnDestroyCallback callback in destroyCallbacks) {
        if (callback) {
            callback();
        }
    }
}

- (NSMutableArray *)onDestroyCallbacks
{
    if (!_onDestroyCallbacks) {
        _onDestroyCallbacks = [NSMutableArray array];
    }
    return _onDestroyCallbacks;
}

- (id<MLNUIConvertorProtocol>)convertor
{
    return _luaCore.convertor;
}

- (id<MLNUIExporterProtocol>)exporter
{
    return _luaCore.exporter;
}

#pragma mark - Private For LuaCore
- (void)setup
{
    // 回调代理
    if ([self.delegate respondsToSelector:@selector(willSetupLuaCore:)]) {
        [self.delegate willSetupLuaCore:self];
    }
    // 创建新的LuaCore
    [self luaCore];
    
    PSTART_TAG(MLNUILoadTimeStatisticsType_Custom, @"other");
    // 注册Kit所有Bridge, 兼容老代码
    [self registerKitClasses];
    // 开启所有处理引擎
    [self startAllEngines];
    // 创建LuaWindow
    PSTART_TAG(MLNUILoadTimeStatisticsType_Custom, @"other2");
    [self setupLuaWindow:_windowExtra];
    PEND_TAG_INFO(MLNUILoadTimeStatisticsType_Custom, @"other2", @"【其他初始化-window】");
    // 将LuaWindow加入到Layout引擎
    [self pushWindowToLayoutEngine];
    PEND_TAG_INFO(MLNUILoadTimeStatisticsType_Custom, @"other", @"【其他初始化】");


    // 回调代理
    if ([self.delegate respondsToSelector:@selector(didSetupLuaCore:)]) {
        [self.delegate didSetupLuaCore:self];
    }
}

- (void)createLuaCore
{
    if (self.luaCoreBuilder) {
        _luaCore = [self.luaCoreBuilder getLuaCore];
    } else {
        _luaCore = [[MLNUILuaCore alloc] initWithLuaBundle:_currentBundle convertor:_convertorClass exporter:_exporterClass];
    }
    [_luaCore changeLuaBundle:self.currentBundle];
    _luaCore.weakAssociatedObject = self;
    _luaCore.errorHandler = self;
    _luaCore.delegate = self;
}


- (void)startAllEngines
{
    [self.layoutEngine start];
    [self.lazyTaskEngine start];
    [self.animationEngine start];
    [self.renderEngine start];
}

- (void)forceLayoutLuaWindow
{
    [self.luaWindow mlnui_requestLayoutIfNeed];
}

- (void)releaseAll
{
    // 回调代理
    if ([self.delegate respondsToSelector:@selector(willReleaseLuaCore:)]) {
        [self.delegate willReleaseLuaCore:self];
    }
    // 停止所有处理引擎
    [self stopAllEngines];
    // 释放window
    [self releaseLuaWindow];
    // 回调Callback
    [self doOnDestroyCallbacks];
    // 释放内核
    _luaCore = nil;
    // 回调代理
    if ([self.delegate respondsToSelector:@selector(didReleaseLuaCore:)]) {
        [self.delegate didReleaseLuaCore:self];
    }
}

- (void)stopAllEngines
{
    [_layoutEngine end];
    _layoutEngine = nil;
    
    [_lazyTaskEngine end];
    _lazyTaskEngine = nil;
    
    [_animationEngine end];
    _animationEngine = nil;
    
    [_renderEngine end];
    _renderEngine = nil;
}

- (void)releaseLuaWindow
{
   // 通知Lua，Window即将释放
    [self.luaWindow doLuaViewDestroy];
    // 释放Lua Window
    [self.luaWindow  luaui_removeAllSubViews];
    [self.luaWindow  removeFromSuperview];
    _luaWindow  = nil;
}

#pragma mark - Getter
- (MLNUILuaCore *)luaCore
{
    if (!_luaCore) {
        PSTART(MLNUILoadTimeStatisticsType_LuaCore);
        [self createLuaCore];
        PEND(MLNUILoadTimeStatisticsType_LuaCore);
    }
    return _luaCore;
}

- (MLNUILayoutEngine *)layoutEngine
{
    if (!_layoutEngine) {
        _layoutEngine = [[MLNUILayoutEngine alloc] initWithLuaInstance:self];
    }
    return _layoutEngine;
}

- (MLNUIBeforeWaitingTaskEngine *)lazyTaskEngine
{
    if (!_lazyTaskEngine) {
        _lazyTaskEngine = [[MLNUIBeforeWaitingTaskEngine alloc] initWithLuaInstance:self order:kMLNUIRunLoopBeforeWaitingLazyTaskOrder];
    }
    return _lazyTaskEngine;
}

- (MLNUIBeforeWaitingTaskEngine *)animationEngine
{
    if (!_animationEngine) {
        _animationEngine = [[MLNUIBeforeWaitingTaskEngine alloc] initWithLuaInstance:self order:kMLNUIRunLoopBeforeWaitingAnimtaionOrder];
    }
    return _animationEngine;
}

- (MLNUIBeforeWaitingTaskEngine *)renderEngine
{
    if (!_renderEngine) {
        _renderEngine = [[MLNUIBeforeWaitingTaskEngine alloc] initWithLuaInstance:self order:kMLNUIRunLoopBeforeWaitingRenderOrder];
    }
    return _renderEngine;
}

- (NSMutableArray<Class<MLNUIExportProtocol>> *)innerRegisterClasses
{
    if (!_innerRegisterClasses) {
        _innerRegisterClasses = [NSMutableArray arrayWithArray:@[[MLNUIWindow class]]];
    }
    return _innerRegisterClasses;
}

- (NSArray<Class<MLNUIExportProtocol>> *)registerClasses
{
    return self.innerRegisterClasses.copy;
}

@end

@implementation MLNUIKitInstance (Layout)

- (void)addRootnode:(MLNUILayoutNode *)rootnode
{
    [self.layoutEngine addRootnode:rootnode];
}

- (void)removeRootNode:(MLNUILayoutNode *)rootnode
{
    [self.layoutEngine removeRootNode:rootnode];
}

- (void)requestLayout
{
    [self.layoutEngine requestLayout];
}

@end

@implementation MLNUIKitInstance (LazyTask)

- (void)pushLazyTask:(id<MLNUIBeforeWaitingTaskProtocol>)lazyTask
{
    [self.lazyTaskEngine pushTask:lazyTask];
}

- (void)forcePushLazyTask:(id<MLNUIBeforeWaitingTaskProtocol>)lazyTask
{
    [self.lazyTaskEngine forcePushTask:lazyTask];
}

- (void)popLazyTask:(id<MLNUIBeforeWaitingTaskProtocol>)lazyTask
{
    [self.lazyTaskEngine popTask:lazyTask];
}

#pragma mark - Animations
- (void)pushAnimation:(id<MLNUIBeforeWaitingTaskProtocol>)animation
{
    [self.animationEngine pushTask:animation];
}

- (void)popAnimation:(id<MLNUIBeforeWaitingTaskProtocol>)animation
{
    [self.animationEngine popTask:animation];
}

#pragma mark - Render
- (void)pushRenderTask:(id<MLNUIBeforeWaitingTaskProtocol>)renderTask
{
    [self.renderEngine pushTask:renderTask];
}

- (void)popRenderTask:(id<MLNUIBeforeWaitingTaskProtocol>)renderTask
{
    [self.renderEngine popTask:renderTask];
}

@end

@implementation MLNUIKitInstance (GC)

- (void)doGC
{
    [_luaCore doGC];
}

@end


@implementation MLNUIKitInstance (Deprecated)

- (instancetype)initWithLuaBundle:(MLNUILuaBundle *)bundle rootView:(UIView * _Nullable)rootView viewController:(nonnull UIViewController<MLNUIViewControllerProtocol> *)viewController
{
    return [self initWithLuaBundle:bundle convertor:nil exporter:nil rootView:rootView viewController:viewController];
}

- (instancetype)initWithLuaBundle:(MLNUILuaBundle *__nullable)luaBundle convertor:(Class<MLNUIConvertorProtocol> __nullable)convertorClass exporter:(Class<MLNUIExporterProtocol> __nullable)exporterClass rootView:(UIView *)rootView viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController
{
    if (self = [super init]) {
        _currentBundle = luaBundle;
        if (!convertorClass) {
            convertorClass = ArgoBindingConvertor.class;
        }
        _convertorClass = convertorClass;
        _exporterClass = exporterClass;
        _rootView = rootView;
        _viewController = viewController;
        _instanceHandlersManager = [[MLNUIKitInstanceHandlersManager alloc] initWithUIInstance:self];
        _bridgesManager = [[MLNUIKitBridgesManager alloc] initWithUIInstance:self];
        _instanceConsts = [[MLNUIKitInstanceConsts alloc] init];
    }
    return self;
}

- (void)registerKitClasses
{
    [self.bridgesManager registerKit];
}
@end
