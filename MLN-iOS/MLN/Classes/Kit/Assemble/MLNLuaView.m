//
//  MLNLuaView.m
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/10.
//

#import "MLNLuaView.h"
#import "MLNKitInstance.h"
#import "MLNLuaCore.h"
#import "MLNViewInspectorManager.h"
#import "MLNViewLoader.h"
#import "MLNViewLoadModel.h"
#import "MLNLoadWindowInspector.h"
#import "MLNLuaWindowLayoutInspector.h"
#import "MLNLuaViewDefaultURLParseInspector.h"
#import "MLNLuaViewInspectorBuilderProtocol.h"

static NSString *observerWindowKeyPath = @"instance.luaWindow.frame";
static NSString *observerRootKeyPath = @"superview.frame";

static int mln_errorFunc_traceback (lua_State *L) {
    if(!lua_isstring(L,1))
        return 1;
    lua_getfield(L,LUA_GLOBALSINDEX,"debug");
    if(!lua_istable(L,-1)) {
        lua_pop(L,1);
        return 1;
    }
    lua_getfield(L,-1,"traceback");
    if(!lua_isfunction(L,-1)) {
        lua_pop(L,2);
        return 1;
    }
    lua_pushvalue(L,1);
    lua_pushinteger(L,2);
    lua_call(L,2,1);
    return 1;
}

@interface MLNLuaView()

@property (nonatomic, weak) MLNViewLoadModel *loadModel;
@property (nonatomic, strong) MLNViewLoader *loader;
@property (nonatomic, assign) BOOL hasWindowObserver;
@property (nonatomic, assign) BOOL hasRootObserver;
@property (nonatomic, strong) UIView *errorView;

@end

@implementation MLNLuaView

+ (instancetype)luaViewWithUrl:(NSString *)urlStr {
    return [self luaViewWithUrl:urlStr
             withInspectBuilder:nil];
}

+ (instancetype)luaViewWithUrl:(NSString *)urlStr
            withInspectBuilder:(id<MLNLuaViewInspectorBuilderProtocol> __nullable) buider {
    
    return [self luaViewWithUrl:urlStr
                  withSuperView:nil
                 withHeightType:MLNLayoutMeasurementTypeWrapContent
                  withWidthType:MLNLayoutMeasurementTypeWrapContent
             withInspectBuilder:buider];
}

+ (instancetype)luaViewWithUrl:(NSString *)urlStr
                      withSize:(CGSize) size
                withHeightType:(MLNLayoutMeasurementType) heightType
                 withWidthType:(MLNLayoutMeasurementType) widthType {
    return [self luaViewWithUrl:urlStr
                       withSize:size
                 withHeightType:heightType
                  withWidthType:widthType
             withInspectBuilder:nil];
}

+ (instancetype)luaViewWithUrl:(NSString *)urlStr
                      withSize:(CGSize) size
                withHeightType:(MLNLayoutMeasurementType) heightType
                 withWidthType:(MLNLayoutMeasurementType) widthType
            withInspectBuilder:(id<MLNLuaViewInspectorBuilderProtocol> __nullable) buider {
    return [self luaViewWithUrl:urlStr
                  withSuperView:nil
                       withSize:size
                 withHeightType:heightType
                  withWidthType:widthType
             withInspectBuilder:buider];
}

+ (instancetype)luaViewWithUrl:(NSString *)urlStr
                 withSuperView:(UIView * __nullable) view
                withHeightType:(MLNLayoutMeasurementType) heightType
                 withWidthType:(MLNLayoutMeasurementType) widthType {
    return [self luaViewWithUrl:urlStr
                      withSuperView:view
                     withHeightType:heightType
                      withWidthType:widthType
                 withInspectBuilder:nil];
    
}

+ (instancetype)luaViewWithUrl:(NSString *)urlStr
                 withSuperView:(UIView * __nullable) view
                withHeightType:(MLNLayoutMeasurementType) heightType
                 withWidthType:(MLNLayoutMeasurementType) widthType
            withInspectBuilder:(id<MLNLuaViewInspectorBuilderProtocol> __nullable) buider {
    return [self luaViewWithUrl:urlStr
           withSuperView:view
                withSize:CGSizeZero
          withHeightType:heightType
           withWidthType:widthType
      withInspectBuilder:buider];
}

+ (instancetype)luaViewWithUrl:(NSString *)urlStr
                 withSuperView:(UIView * __nullable) view
                      withSize:(CGSize) size
                withHeightType:(MLNLayoutMeasurementType) heightType
                 withWidthType:(MLNLayoutMeasurementType) widthType
            withInspectBuilder:(id<MLNLuaViewInspectorBuilderProtocol> __nullable) buider {
    NSAssert([NSThread isMainThread], @"This method to be executed in the main thread!");
    MLNViewLoader *loader = [self creatLoderWithBuilder:buider];
    MLNViewLoadModel *loadModel = [[MLNViewLoadModel alloc] init];
    loadModel.loader = loader;
    loadModel.urlStr = urlStr;
    loadModel.heightLayoutStrategy = heightType;
    loadModel.widthLayoutStrategy = widthType;
    loadModel.rootView = view;
    //set correct size
    if (view) {
        loadModel.size = view.bounds.size;
    } else {
        loadModel.size = size;
    }
    if (CGSizeEqualToSize(loadModel.size, CGSizeZero)) {
        loadModel.size = [UIScreen mainScreen].bounds.size;
    }
    if ([buider respondsToSelector:@selector(registerClasses)]) {
        loadModel.suppleLuaBridgeClasses = [buider registerClasses];
    }
    if ([buider respondsToSelector:@selector(pipelineHandle)]) {
        loadModel.pipelineHandle = [buider pipelineHandle];
    }
    [loadModel.pipelineHandle willSetupMLNView];
    if ([buider respondsToSelector:@selector(detectItem)]) {
        loadModel.detectItem = [buider detectItem];
    }
    
    [loader loadView:loadModel];
    if ([loadModel.luaView isKindOfClass:[MLNLuaView class]]) {
        loadModel.luaView.loader = loader;
        return loadModel.luaView;
    }
    MLNLuaView *warpView = [[MLNLuaView alloc] initWithFrame:CGRectMake(0, 0,
                                                                        loadModel.size.width,
                                                                        loadModel.size.height)];
    [warpView addSubview:loadModel.luaView];
    warpView.errorView = loadModel.luaView;
    return warpView;
}

+ (void) warmup {
//    NSString* urlStr = @"https://test.com?_identfier=101222&enterFilePath=test&version=1.2.3";
//    [MLNLuaView luaViewWithUrl:urlStr];
}

+ (MLNViewLoader *)creatLoderWithBuilder:(id<MLNLuaViewInspectorBuilderProtocol>) buider  {
    MLNViewInspectorManager *inspectorManager = [[MLNViewInspectorManager alloc] initInspectorManager];
    if (buider) {
        if ([buider respondsToSelector:@selector(errorCacheInspectors)]) {
            [inspectorManager addErrorCatchInspector:[buider errorCacheInspectors]];
        }
        if ([buider respondsToSelector:@selector(logUploader)]) {
            [inspectorManager addLogUploader:[buider logUploader]];
        }
        [inspectorManager addErrorViewBuilder:[buider errorViewInspector]];
        if ([buider respondsToSelector:@selector(urlParselInspectors)]) {
            [inspectorManager addUrlParselInspectors:[buider urlParselInspectors]];
        }
        if ([buider respondsToSelector:@selector(resourceManageInspectors)]) {
            [inspectorManager addResourceManageInspectors:[buider resourceManageInspectors]];
        }
    }
    MLNViewLoader *loader = [[MLNViewLoader alloc] init];
    loader.inspectorManager = inspectorManager;
    return loader;
}

- (id)updateCustomView:(NSMutableDictionary *) map
{
    if (self.errorView) {
        self.frame = CGRectMake(CGRectGetMinX(self.frame),
                                CGRectGetMinY(self.frame),
                                CGRectGetWidth(self.errorView.bounds),
                                CGRectGetHeight(self.errorView.bounds));
        return nil;
    }
    NSAssert([NSThread isMainThread], @"This method to be executed in the main thread!");
    MLNKitInstance *instance = self.instance;
    MLNLuaCore *core = instance.luaCore;
    lua_State *L = core.state;
    if (L == NULL) {
        return nil;
    }
    int base = lua_gettop(L);
    // 添加error处理函数
    lua_pushcfunction(L, mln_errorFunc_traceback);
    // Lua Fucntion 压栈
    lua_getglobal(L, "updateView");
    mln_lua_checkfunc(L, -1);
    // 参数压栈
    if (![core pushNativeObject:map error:NULL]) {
        // 恢复栈
        lua_settop(L, base);
        return nil;
    }
    // 调用
    int success = lua_pcall(L, 1, 1, base + 1);
    id result = nil;
    if (success == 0) {
        if (lua_gettop(L) > base) {
            result = [core toNativeObject:-1 error:NULL];
        }
        [instance requestLayout];
    } else {
        NSString *msg = [NSString stringWithUTF8String:lua_tostring(L, -1)];
        MLNError(MLN_LUA_CORE(L), @"fail to call lua function! error message: %@", msg);
    }
    // 恢复栈
    lua_settop(L, base);
    return result;
}

- (void)setInstance:(MLNKitInstance *) instance {
    NSAssert([NSThread isMainThread], @"This method to be executed in the main thread!");
    _instance = instance;
    [self creatWindowObserverIfNeed];
}

- (void)setLoadModel:(MLNViewLoadModel *)loadModel {
    NSAssert([NSThread isMainThread], @"This method to be executed in the main thread!");
    _loadModel = loadModel;
    [self creatRootObserverIfNeed];
    
}

- (void)creatWindowObserverIfNeed {
    if (!self.hasWindowObserver) {
        self.hasWindowObserver = YES;
        [self addObserver:self forKeyPath:observerWindowKeyPath
                  options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
    }
}

- (void)creatRootObserverIfNeed {
    if ((self.loadModel.widthLayoutStrategy == MLNLayoutMeasurementTypeMatchParent ||
         self.loadModel.heightLayoutStrategy == MLNLayoutMeasurementTypeMatchParent)
        && !self.hasRootObserver && self.superview) {
        self.hasRootObserver = YES;
        [self addObserver:self forKeyPath:observerRootKeyPath
                  options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([observerWindowKeyPath isEqualToString:keyPath]) {
        CGRect new = [((NSValue *)[change objectForKey:@"new"]) CGRectValue];
        CGRect old = [((NSValue *)[change objectForKey:@"old"]) CGRectValue];
        MLNKitInstance *instance = self.instance;
        if (!CGRectEqualToRect(new, old) && instance) {
            UIView *view = (id)instance.luaWindow;
            CGSize rSize = view.bounds.size;
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, rSize.width, rSize.height);
        }
        return;
    }
    
    if ([observerRootKeyPath isEqualToString:keyPath]) {
        CGRect new = [((NSValue *)[change objectForKey:@"new"]) CGRectValue];
        CGRect old = [((NSValue *)[change objectForKey:@"old"]) CGRectValue];
        MLNKitInstance *instance = self.instance;
        if (!CGSizeEqualToSize(new.size, old.size) && instance) {
            //call instance relayout
            self.loadModel.size = new.size;
            self.loadModel.windowExtro[@"size"] = @(self.loadModel.size);
            instance.windowExtra = self.loadModel.windowExtro;
            [instance setLayoutInfo];
        }
        return;
    }
    
}


- (CGSize)sizeThatFits:(CGSize) size {
    MLNKitInstance *instance = self.instance;
    if (!instance) {
        return size;
    }
    UIView *view = (id)instance.luaWindow;
    CGSize rSize = view.bounds.size;
    return rSize;
}

-(void)dealloc {
    NSLog(@"%s",__func__);
    if (self.hasWindowObserver) {
        [self removeObserver:self forKeyPath:observerWindowKeyPath];
    }
    if (self.hasRootObserver) {
        [self removeObserver:self forKeyPath:observerRootKeyPath];
    }
}
@end
