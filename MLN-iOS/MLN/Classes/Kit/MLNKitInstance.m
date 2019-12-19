//
//  MLNInstance.m
//  MLN
//
//  Created by MoMo on 2019/8/3.
//

#import "MLNKitInstance.h"
#import "MLNLuaCore.h"
#import "MLNLuaTable.h"
#import "MLNLayoutEngine.h"
#import "MLNBeforeWaitingTaskEngine.h"
#import "MLNKiConvertor.h"
#import "UIView+MLNLayout.h"
#import "MLNLayoutContainerNode.h"
#import "MLNKitInstanceHandlersManager.h"
#import "MLNWindow.h"
#import "MLNKitInstanceConsts.h"

#define kMLNRunLoopBeforeWaitingLazyTaskOrder   1
#define kMLNRunLoopBeforeWaitingRenderOrder     2
#define kMLNRunLoopBeforeWaitingAnimtaionOrder  3

@interface MLNKitInstance ()<MLNErrorHandlerProtocol, MLNLuaCoreDelegate> {
    MLNLuaCore *_luaCore;
    MLNLayoutEngine *_layoutEngine;
    MLNWindow *_luaWindow;
}
@property (nonatomic, strong) id<MLNKitLuaCoeBuilderProtocol> luaCoreBuilder;
@property (nonatomic, strong) NSMutableDictionary *windowExtra;
@property (nonatomic, strong) NSMutableArray<Class<MLNExportProtocol>> *classes;
@property (nonatomic, strong) MLNBeforeWaitingTaskEngine *lazyTaskEngine;
@property (nonatomic, strong) MLNBeforeWaitingTaskEngine *animationEngine;
@property (nonatomic, strong) MLNBeforeWaitingTaskEngine *renderEngine;
@property (nonatomic, strong) NSMutableArray *onDestroyCallbacks;
@property (nonatomic, assign) BOOL didViewAppear;
@property (nonatomic, assign) BOOL needCallAppear;

@end

@implementation MLNKitInstance (LuaWindow)

- (MLNWindow *)createLuaWindow
{
    return [[MLNWindow alloc] initWithLuaCore:self.luaCore frame:self.rootView.bounds];
}

- (void)setupLuaWindow:(NSMutableDictionary *)windowExtra
{
    if (!self.luaWindow) {
        _luaWindow = [self createLuaWindow];
    }
    self.luaWindow.extraInfo = windowExtra;
    [self.luaCore registerGlobalVar:self.luaWindow globalName:@"window" error:nil];
    self.luaWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.rootView addSubview:self.luaWindow];
}

- (void)pushWindowToLayoutEngine
{
    __unsafe_unretained MLNLayoutContainerNode *node = (MLNLayoutContainerNode *)self.luaWindow.lua_node;
    node.heightType = MLNLayoutMeasurementTypeIdle;
    node.widthType = MLNLayoutMeasurementTypeIdle;
    [node changeX:0.f];
    [node changeY:0.f];
    [node changeWidth:self.rootView.bounds.size.width];
    [node changeHeight:self.rootView.bounds.size.height];
    node.root = YES;
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

@implementation MLNKitInstance

#pragma mark - MLNErrorHandlerProtocol
- (BOOL)canHandleAssert:(MLNLuaCore *)luaCore
{
    return [self.instanceHandlersManager.errorHandler canHandleAssert:self];
}

- (void)luaCore:(MLNLuaCore *)luaCore error:(NSString *)error
{
    [self.instanceHandlersManager.errorHandler instance:self error:error];
}

- (void)luaCore:(MLNLuaCore *)luaCore luaError:(NSString *)error luaTraceback:(NSString *)luaTraceback
{
    [self.instanceHandlersManager.errorHandler instance:self luaError:error luaTraceback:luaTraceback];
}

#pragma mark - MLNLuaCoreDelegate
- (void)luaCore:(MLNLuaCore *)luaCore willLoad:(NSData *)data filePath:(NSString *)filePath
{
    if ([self.delegate respondsToSelector:@selector(instance:willLoad:fileName:)]) {
        [self.delegate instance:self willLoad:data fileName:filePath];
    }
}

- (void)luaCore:(MLNLuaCore *)luaCore didLoad:(NSData *)data filePath:(NSString *)filePath
{
    if ([self.delegate respondsToSelector:@selector(instance:didLoad:fileName:)]) {
        [self.delegate instance:self didLoad:data fileName:filePath];
    }
}

- (void)luaCore:(MLNLuaCore *)luaCore didFailLoad:(NSData *)data filePath:(NSString *)filePath error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(instance:didFailLoad:fileName:error:)]) {
        [self.delegate instance:self didFailLoad:data fileName:filePath error:error];
    }
}

#pragma mark - Public For LuaCore
- (instancetype)initWithLuaCoreBuilder:(id<MLNKitLuaCoeBuilderProtocol>)luaCoreBuilder viewController:(UIViewController<MLNViewControllerProtocol> *)viewController
{
    return [self initWithLuaBundle:[MLNLuaBundle mainBundle] luaCoreBuilder:luaCoreBuilder viewController:viewController];
}

- (instancetype)initWithLuaBundlePath:(NSString *__nullable)luaBundlePath luaCoreBuilder:(id<MLNKitLuaCoeBuilderProtocol>)luaCoreBuilder viewController:(UIViewController<MLNViewControllerProtocol> *)viewController
{
    return [self initWithLuaBundle:[MLNLuaBundle mainBundleWithPath:luaBundlePath] luaCoreBuilder:luaCoreBuilder viewController:viewController];
}

- (instancetype)initWithLuaBundle:(MLNLuaBundle *__nullable)luaBundle luaCoreBuilder:(id<MLNKitLuaCoeBuilderProtocol>)luaCoreBuilder viewController:(UIViewController<MLNViewControllerProtocol> *)viewController
{
    return [self initWithLuaBundle:luaBundle luaCoreBuilder:luaCoreBuilder rootView:nil viewController:viewController];
}

- (instancetype)initWithLuaBundle:(MLNLuaBundle *__nullable)luaBundle luaCoreBuilder:(id<MLNKitLuaCoeBuilderProtocol>)luaCoreBuilder rootView:(UIView *)rootView viewController:(UIViewController<MLNViewControllerProtocol> *)viewController
{
    if (self = [super init]) {
        _currentBundle = luaBundle;
        _luaCoreBuilder = luaCoreBuilder;
        _rootView = rootView;
        _viewController = viewController;
        _instanceHandlersManager = [[MLNKitInstanceHandlersManager alloc] initWithUIInstance:self];
        _instanceConsts = [[MLNKitInstanceConsts alloc] init];
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
            *error = [NSError mln_errorCall:@"entry file is nil!"];
        }
        MLNError(self.luaCore, @"entry file is nil!");
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
        [self forceLayoutLuaWindow];
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
    MLNAssert(self.luaCore, (entryFilePath && entryFilePath.length >0), @"entry file is nil!");
    // 释放当前环境
    [self releaseAll];
    self.needCallAppear = YES;
    // 更新参数配置
    _windowExtra = [NSMutableDictionary dictionaryWithDictionary:windowExtra];
    _entryFilePath = entryFilePath;
    // 准备环境
    [self setup];
    // 注册bridge
    if (![self.luaCore registerClasses:_classes error:error]) {
        return NO;
    }
    // 执行
    if ([self runWithEntryFile:entryFilePath error:error]) {
        [self redoLuaViewDidAppearIfNeed];
        return YES;
    }
    return NO;
    
}

- (BOOL)registerClazz:(Class<MLNExportProtocol>)clazz error:(NSError * _Nullable __autoreleasing *)error
{
    [self.classes addObject:clazz];
    return [self.luaCore registerClazz:clazz error:error];
}

- (BOOL)registerClasses:(NSArray<Class<MLNExportProtocol>> *)classes error:(NSError * _Nullable __autoreleasing *)error
{
    [self.classes addObjectsFromArray:classes];
    return [self.luaCore registerClasses:classes error:error];
}

- (void)changeLuaBundleWithPath:(NSString *)bundlePath
{
    _currentBundle = [[MLNLuaBundle alloc] initWithBundlePath:bundlePath];
    [self.luaCore changeLuaBundle:_currentBundle];
}

- (void)changeLuaBundle:(MLNLuaBundle *)bundle
{
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

- (void)setStrongObject:(id<MLNEntityExportProtocol>)obj key:(NSString *)key
{
    [self.luaCore setStrongObject:obj key:key];
}

- (void)setStrongObject:(id<MLNEntityExportProtocol>)obj cKey:(nonnull void *)cKey
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

- (void)addOnDestroyCallback:(MLNOnDestroyCallback)callback
{
    if (!callback || [_onDestroyCallbacks containsObject:callback]) {
        return;
    }
    [self.onDestroyCallbacks addObject:callback];
}

- (void)removeOnDestroyCallback:(MLNOnDestroyCallback)callback
{
    if (callback) {
        [_onDestroyCallbacks removeObject:callback];
    }
}

- (void)doOnDestroyCallbacks
{
    NSArray *destroyCallbacks = _onDestroyCallbacks.copy;
    for (MLNOnDestroyCallback callback in destroyCallbacks) {
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

- (id<MLNConvertorProtocol>)convertor
{
    return _luaCore.convertor;
}

- (id<MLNExporterProtocol>)exporter
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
    // 开启所有处理引擎
    [self startAllEngines];
    // 创建LuaWindow
    [self setupLuaWindow:_windowExtra];
    // 将LuaWindow加入到Layout引擎
    [self pushWindowToLayoutEngine];
    // 回调代理
    if ([self.delegate respondsToSelector:@selector(didSetupLuaCore:)]) {
        [self.delegate didSetupLuaCore:self];
    }
}

- (void)createLuaCore
{
    _luaCore = [self.luaCoreBuilder getLuaCore];
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
   [self.luaWindow lua_requestLayout];
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
    [self.luaWindow  lua_removeAllSubViews];
    [self.luaWindow  removeFromSuperview];
    _luaWindow  = nil;
}

#pragma mark - Getter
- (MLNLuaCore *)luaCore
{
    if (!_luaCore) {
        [self createLuaCore];
    }
    return _luaCore;
}

- (MLNLayoutEngine *)layoutEngine
{
    if (!_layoutEngine) {
        _layoutEngine = [[MLNLayoutEngine alloc] initWithLuaInstance:self];
    }
    return _layoutEngine;
}

- (MLNBeforeWaitingTaskEngine *)lazyTaskEngine
{
    if (!_lazyTaskEngine) {
        _lazyTaskEngine = [[MLNBeforeWaitingTaskEngine alloc] initWithLuaInstance:self order:kMLNRunLoopBeforeWaitingLazyTaskOrder];
    }
    return _lazyTaskEngine;
}

- (MLNBeforeWaitingTaskEngine *)animationEngine
{
    if (!_animationEngine) {
        _animationEngine = [[MLNBeforeWaitingTaskEngine alloc] initWithLuaInstance:self order:kMLNRunLoopBeforeWaitingAnimtaionOrder];
    }
    return _animationEngine;
}

- (MLNBeforeWaitingTaskEngine *)renderEngine
{
    if (!_renderEngine) {
        _renderEngine = [[MLNBeforeWaitingTaskEngine alloc] initWithLuaInstance:self order:kMLNRunLoopBeforeWaitingRenderOrder];
    }
    return _renderEngine;
}

- (NSMutableArray<Class<MLNExportProtocol>> *)classes
{
    if (!_classes) {
        _classes = [NSMutableArray arrayWithArray:@[[MLNWindow class]]];
    }
    return _classes;
}

@end

@implementation MLNKitInstance (Layout)

- (void)addRootnode:(MLNLayoutContainerNode *)rootnode
{
    [self.layoutEngine addRootnode:rootnode];
}

- (void)removeRootNode:(MLNLayoutContainerNode *)rootnode
{
    [self.layoutEngine removeRootNode:rootnode];
}

- (void)requestLayout
{
    [self.layoutEngine requestLayout];
}

@end

@implementation MLNKitInstance (LazyTask)

- (void)pushLazyTask:(id<MLNBeforeWaitingTaskProtocol>)lazyTask
{
    [self.lazyTaskEngine pushTask:lazyTask];
}

- (void)popLazyTask:(id<MLNBeforeWaitingTaskProtocol>)lazyTask
{
    [self.lazyTaskEngine popTask:lazyTask];
}

#pragma mark - Animations
- (void)pushAnimation:(id<MLNBeforeWaitingTaskProtocol>)animation
{
    [self.animationEngine pushTask:animation];
}

- (void)popAnimation:(id<MLNBeforeWaitingTaskProtocol>)animation
{
    [self.animationEngine popTask:animation];
}

#pragma mark - Render
- (void)pushRenderTask:(id<MLNBeforeWaitingTaskProtocol>)renderTask
{
    [self.renderEngine pushTask:renderTask];
}

- (void)popRenderTask:(id<MLNBeforeWaitingTaskProtocol>)renderTask
{
    [self.renderEngine popTask:renderTask];
}

@end

@implementation MLNKitInstance (GC)

- (void)doGC
{
    [_luaCore doGC];
}

@end
