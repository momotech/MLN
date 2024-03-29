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
#import "MLNFile.h"
#import "MLNKitBridgesManager.h"
#import "MLNListDetectItem.h"
#import "MLNImpoterManager.h"
#import "MLNDependenceManager.h"
#import "MLNDependence.h"

#define kMLNRunLoopBeforeWaitingLazyTaskOrder   1
#define kMLNRunLoopBeforeWaitingRenderOrder     2
#define kMLNRunLoopBeforeWaitingAnimtaionOrder  3

@interface MLNKitInstance ()<MLNErrorHandlerProtocol, MLNLuaCoreDelegate> {
    MLNLuaCore *_luaCore;
    MLNLayoutEngine *_layoutEngine;
    MLNWindow *_luaWindow;
}
@property (nonatomic, strong) id<MLNKitLuaCoeBuilderProtocol> luaCoreBuilder;
@property (nonatomic, strong) NSMutableArray<Class<MLNExportProtocol>> *classes;
@property (nonatomic, strong) MLNBeforeWaitingTaskEngine *lazyTaskEngine;
@property (nonatomic, strong) MLNBeforeWaitingTaskEngine *animationEngine;
@property (nonatomic, strong) MLNBeforeWaitingTaskEngine *renderEngine;
@property (nonatomic, strong) NSMutableArray *onDestroyCallbacks;
@property (nonatomic, assign) MLNLayoutMeasurementType widthLayoutStrategy;
@property (nonatomic, assign) MLNLayoutMeasurementType heightLayoutStrategy;
@property (nonatomic, assign) BOOL didViewAppear;
@property (nonatomic, assign) BOOL needCallAppear;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) MLNDependence *dependece;

@end

// Deprecated
@interface MLNKitInstance ()
@property (nonatomic) Class<MLNConvertorProtocol> convertorClass;
@property (nonatomic) Class<MLNExporterProtocol> exporterClass;
@property (nonatomic, strong) MLNKitBridgesManager *bridgesManager;

@end

@implementation MLNKitInstance (LuaWindow)

- (void)pushWindowToLayoutEngine
{
    __unsafe_unretained MLNLayoutContainerNode *node = nil;
    if ([self.identifier isEqualToString:@"MLNLuaView"]) {
        node = [self setViewLayoutInfo];
    } else {
        node = [self setLayoutInfo];
    }
    node.root = YES;
    [self.layoutEngine addRootnode:node];
}

-(MLNLayoutContainerNode *)setLayoutInfo {
    self.heightLayoutStrategy = MLNLayoutMeasurementTypeIdle;
    self.widthLayoutStrategy = MLNLayoutMeasurementTypeIdle;
    self.size = CGSizeMake(CGRectGetWidth(self.rootView.bounds), CGRectGetHeight(self.rootView.bounds));
    __unsafe_unretained MLNLayoutContainerNode *node = [self setViewLayoutInfo];
    return node;
}

-(MLNLayoutContainerNode *)setViewLayoutInfo {
    __unsafe_unretained MLNLayoutContainerNode *node = (MLNLayoutContainerNode *)self.luaWindow.lua_node;
    node.heightType = self.heightLayoutStrategy;
    node.widthType = self.widthLayoutStrategy;
    [node changeX:0.f];
    [node changeY:0.f];
    switch (node.heightType) {
        case MLNLayoutMeasurementTypeWrapContent:
        {
            CGFloat height = (self.size.height > CGRectGetHeight([UIScreen mainScreen].bounds)) ? self.size.height : CGRectGetHeight([UIScreen mainScreen].bounds);
            [node changeHeight:height];
            [node setMaxHeight:height];
            break;
        }
        case MLNLayoutMeasurementTypeMatchParent:
        default:
            [node changeHeight:self.size.height];
            [node setMaxHeight:self.size.height];
            break;
    }
    
    switch (node.widthType) {
        case MLNLayoutMeasurementTypeWrapContent:
        {
            CGFloat width = self.size.width > CGRectGetWidth([UIScreen mainScreen].bounds) ? self.size.width : CGRectGetWidth([UIScreen mainScreen].bounds);
            [node changeWidth:width];
            [node setMaxWidth:width];
            break;
        }
        case MLNLayoutMeasurementTypeMatchParent:
        default:
            [node changeWidth:self.size.width];
            [node setMaxWidth:self.size.width];
            break;
    }
    return node;
}

- (void)transformWindowExtra {
    if (self.windowExtra.count) {
        CGSize size = [(NSValue *)[self.windowExtra objectForKey:@"size"] CGSizeValue];
        if (!CGSizeEqualToSize(self.luaWindow.bounds.size, size)) {
            self.size = size;
        }
        self.identifier = [self.windowExtra objectForKey:@"identifier"];
        self.widthLayoutStrategy = [[self.windowExtra objectForKey:@"widthLayoutStrategy"] integerValue];
        self.heightLayoutStrategy = [[self.windowExtra objectForKey:@"heightLayoutStrategy"] integerValue];
    }
}

- (void)doLuaWindowDidAppear
{
    self.didViewAppear = YES;
    for ( void (^appearBlock)(void) in self.appearMArray) {
        appearBlock ? appearBlock() : nil;
    }
    if (self.luaWindow && [self.luaWindow canDoLuaViewDidAppear]) {
        [self.luaWindow doLuaViewDidAppear:MLNWindowAppearTypeViewAppear];
        self.needCallAppear = NO;
        return;
    }
    self.needCallAppear = YES;
}

- (void)redoLuaViewDidAppearIfNeed
{
    if (self.needCallAppear && self.didViewAppear) {
        [self.luaWindow doLuaViewDidAppear:MLNWindowAppearTypeViewAppear];
    }
}

- (void)doLuaWindowDidDisappear
{
    self.didViewAppear = NO;
    if (self.luaWindow && [self.luaWindow canDoLuaViewDidDisappear]) {
        [self.luaWindow doLuaViewDidDisappear:MLNWindowDisappearTypeViewDisappear];
    }
}

- (void)changeLuaWindowSize:(CGSize)newSize
{
    CGRect newFrame = self.luaWindow.frame;
    newFrame.size.width = newSize.width;
    newFrame.size.height = newSize.height;
    self.size = newSize;
    self.luaWindow.frame = newFrame;
}

@end

@implementation MLNKitInstance

- (void)setWindowExtra:(NSMutableDictionary *)windowExtra {
    _windowExtra = windowExtra;
    [self transformWindowExtra];
}

- (MLNWindow *)createLuaWindow
{
    CGRect bounds = CGRectZero;
    bounds.size = CGSizeEqualToSize(self.size, CGSizeZero) ? [UIScreen mainScreen].bounds.size : self.size;
    self.size = bounds.size;
    return [[MLNWindow alloc] initWithLuaCore:self.luaCore frame:bounds];
}

- (void)setupLuaWindow:(NSMutableDictionary *)windowExtra
{
    if (!self.luaWindow) {
        _luaWindow = [self createLuaWindow];
    }
    self.windowExtra = windowExtra;
    self.luaWindow.extraInfo = windowExtra;
    [self.luaCore registerGlobalVar:self.luaWindow globalName:@"window" error:nil];
    self.luaWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.rootView addSubview:self.luaWindow];
}

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

- (NSData *)luaCore:(MLNLuaCore *)luaCore tryLoad:(NSString *)currentPath filePath:(NSString *)filePath
{
    NSString *fileName = [filePath stringByReplacingOccurrencesOfString:@".lua" withString:@""];
    if (self.widgetInfo.count &&
        fileName.length &&
        self.widgetInfo[fileName]) {//优先查找优化依赖
        NSString *path = self.widgetInfo[fileName];
        NSData *data = [NSData dataWithContentsOfFile:path];
        return data;
    } else if ([self.delegate respondsToSelector:@selector(instance:tryLoad:filePath:)]) {
        return [self.delegate instance:self tryLoad:currentPath filePath:filePath];
    } else {
        return nil;
    }
}

- (BOOL)luaCore:(MLNLuaCore *)luaCore loadBridge:(NSString *)bridgeName {
    if (bridgeName.length) {
        if ([self.delegate respondsToSelector:@selector(instance:loadBridge:)]) {
            return [self.delegate instance:self loadBridge:bridgeName];
        }
    }
    return NO;
}

#pragma mark - Public For LuaCore
- (instancetype)initWithLuaCoreBuilder:(id<MLNKitLuaCoeBuilderProtocol>)luaCoreBuilder viewController:(id<MLNViewControllerProtocol>)viewController
{
    return [self initWithLuaBundle:[MLNLuaBundle mainBundle] luaCoreBuilder:luaCoreBuilder viewController:viewController];
}

- (instancetype)initWithLuaBundlePath:(NSString *__nullable)luaBundlePath luaCoreBuilder:(id<MLNKitLuaCoeBuilderProtocol>)luaCoreBuilder viewController:(id<MLNViewControllerProtocol>)viewController
{
    return [self initWithLuaBundle:[MLNLuaBundle mainBundleWithPath:luaBundlePath] luaCoreBuilder:luaCoreBuilder viewController:viewController];
}

- (instancetype)initWithLuaBundle:(MLNLuaBundle *__nullable)luaBundle luaCoreBuilder:(id<MLNKitLuaCoeBuilderProtocol>)luaCoreBuilder viewController:(id<MLNViewControllerProtocol>)viewController
{
    return [self initWithLuaBundle:luaBundle luaCoreBuilder:luaCoreBuilder rootView:nil viewController:viewController];
}

- (instancetype)initWithLuaBundle:(MLNLuaBundle *__nullable)luaBundle luaCoreBuilder:(id<MLNKitLuaCoeBuilderProtocol>)luaCoreBuilder rootView:(UIView *)rootView viewController:(id<MLNViewControllerProtocol>)viewController
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

- (void)loadDependenceWithLuaBundleRootPath:(NSString *)rootPath withHandle:(id<MLNDependenceProtocol>)handle finished:(void (^)(void))finished {
    
    __weak __typeof(self) weakSelf = self;
    self.dependece = [[MLNDependenceManager shareManager] loadDependenceWithLuaBundleRootPath:rootPath withHandle:handle withInstance:self finished:^(NSDictionary * _Nonnull widgetInfo) {
        weakSelf.widgetInfo = widgetInfo;
        finished ? finished() :nil;
    }];
}

- (void)loadDependenceWithLuaBundleRootPath:(NSString *)rootPath {
    self.widgetInfo = [[MLNDependenceManager shareManager] prepareDependenceWithLuaBundleRootPath:rootPath];
}

- (void)loadDependenceWithLuaBundleRootPath:(NSString *)rootPath finished:(void (^)(void))finished {
    [self loadDependenceWithLuaBundleRootPath:rootPath withHandle:nil finished:finished];
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
    // 注册Kit所有Bridge, 兼容老代码
    [self registerKitClasses];
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
    if (self.luaCoreBuilder) {
        _luaCore = [self.luaCoreBuilder getLuaCore];
    } else {
        _luaCore = [[MLNLuaCore alloc] initWithLuaBundle:_currentBundle convertor:_convertorClass exporter:_exporterClass];
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

-(NSMutableArray<void (^)(void)> *)appearMArray {
    if (!_appearMArray) {
        _appearMArray = [NSMutableArray array];
    }
    return _appearMArray;
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

@implementation MLNKitInstance (Debug)

- (NSString *)loadDebugModelIfNeed {
#if MLN_COULD_LOAD_DEBUG_CONTEXT
    NSString *backupBundlePath = [self.luaCore.currentBundle bundlePath];
    [self changeLuaBundleWithPath:[MLNDebugContext debugBundle].bundlePath];
    NSString *mlndebugPath = [[MLNDebugContext debugBundle] pathForResource:@"mlndebug.lua" ofType:nil];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:mlndebugPath];
    
    BOOL ret = [self.luaCore runData:data name:@"mlndebug.lua" error:&error];
    NSAssert(ret, @"%@", [error.userInfo objectForKey:@"message"]);
    if (!ret) {
        return [error.userInfo objectForKey:@"message"];
    }
    [self changeLuaBundleWithPath:backupBundlePath];
#endif
    return nil;
}

@end

@implementation MLNKitInstance (Deprecated)

- (instancetype)initWithLuaBundle:(MLNLuaBundle *)bundle rootView:(UIView * _Nullable)rootView viewController:(nonnull id<MLNViewControllerProtocol>)viewController
{
    return [self initWithLuaBundle:bundle convertor:nil exporter:nil rootView:rootView viewController:viewController];
}

- (instancetype)initWithLuaBundle:(MLNLuaBundle *__nullable)luaBundle convertor:(Class<MLNConvertorProtocol> __nullable)convertorClass exporter:(Class<MLNExporterProtocol> __nullable)exporterClass rootView:(UIView *)rootView viewController:(id<MLNViewControllerProtocol>)viewController
{
    if (self = [super init]) {
        _currentBundle = luaBundle;
        if (!convertorClass) {
            convertorClass = MLNKiConvertor.class;
        }
        _convertorClass = convertorClass;
        _exporterClass = exporterClass;
        _rootView = rootView;
        _viewController = viewController;
        _instanceHandlersManager = [[MLNKitInstanceHandlersManager alloc] initWithUIInstance:self];
        _bridgesManager = [[MLNKitBridgesManager alloc] initWithUIInstance:self];
        _instanceConsts = [[MLNKitInstanceConsts alloc] init];
    }
    return self;
}

- (void)registerKitClasses
{
    [self.bridgesManager registerKit];
}
@end
