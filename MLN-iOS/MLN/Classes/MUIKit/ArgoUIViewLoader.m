//
//  ArgoUIViewLoader.m
//  ArgoUI
//
//  Created by xindong on 2021/1/25.
//

#import "ArgoUIViewLoader.h"
#import <objc/message.h>
#import "MLNUILuaBundle.h"
#import "ArgoDataBinding.h"
#import "MLNUIKitInstance.h"
#import "MLNUIModelHandler.h"
#import "ArgoObservableMap.h"
#import "ArgoObservableArray.h"
#import "NSObject+ArgoListener.h"
#import "ArgoViewController.h"
#import "MLNUIKitInstanceHandlersManager.h"
@interface ArgoUIViewLoaderDataBinding : ArgoDataBinding
@property (nonatomic, strong) ArgoUIViewLoaderCallback callback;
@end

@implementation ArgoUIViewLoaderDataBinding

#pragma mark - Override

- (void)argo_updateValue:(id)value forKeyPath:(NSString *)keyPath {
    [super argo_updateValue:value forKeyPath:keyPath];
    if (self.callback) {
        self.callback(keyPath, value);
    }
}

@end

@interface ArgoUIViewLoaderKitInstance: MLNUIKitInstance
+ (ArgoUIViewLoaderKitInstance *)kitInstance;
@property (nonatomic, strong) ArgoUIViewLoaderDataBinding *inner_dataBinding;
@property (nonatomic, strong) ArgoObservableMap *observableData;
@end

@interface ArgoUIViewLoaderController : UIViewController<MLNUIViewControllerProtocol>
@property (nonatomic, weak) ArgoUIViewLoaderKitInstance *instance;
@end

@implementation ArgoUIViewLoaderKitInstance {
    UIViewController *_innerController;
}

+ (ArgoUIViewLoaderKitInstance *)kitInstance {
    static UIView *rootView = nil;
    if (!rootView) {
        rootView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    }
    ArgoUIViewLoaderController *controller = [ArgoUIViewLoaderController new];
    ArgoUIViewLoaderKitInstance *instance = [[ArgoUIViewLoaderKitInstance alloc] initWithLuaBundle:[MLNUILuaBundle mainBundle] rootView:rootView viewController:controller];
    instance->_innerController = controller; // retain it or controller will be released.
    controller.instance = instance;
    return instance;
}

- (ArgoUIViewLoaderDataBinding *)inner_dataBinding {
    if (!_inner_dataBinding) {
        _inner_dataBinding = [[ArgoUIViewLoaderDataBinding alloc] init];
    }
    return _inner_dataBinding;
}

@end

@implementation ArgoUIViewLoaderController

#pragma mark - MLNUIViewControllerProtocol

- (MLNUIKitInstance *)kitInstance {
    return _instance;
}

#pragma mark - ArgoDataBindingProtocol

- (ArgoDataBinding *)argo_dataBinding {
    return _instance.inner_dataBinding;
}

@end

static __weak UIView *_view = nil;
static NSUInteger _capacity = 0;
static NSMutableArray<ArgoUIViewLoaderKitInstance *> *_kitQueue = nil;
const char *ArgoUIViewLoaderKitInstanceInstanceKey = "ArgoUIViewLoaderKitInstanceInstanceKey";

@interface ArgoUIViewLoader ()
@property (nonatomic, readonly, class) NSMutableArray<ArgoUIViewLoaderKitInstance *> *kitQueue;
@end

@implementation ArgoUIViewLoader

#pragma mark - Public

+ (void)preload:(NSUInteger)capacity {
    _capacity = capacity;
    [self preload];
}

+ (nullable UIView *)loadViewFromLuaFilePath:(NSString *)filePath modelKey:(nonnull NSString *)modelKey {
//    ArgoUIViewLoaderKitInstance *kit = [self getInstance];
//    kit.modelKey = modelKey;
//
//    NSError *error = nil;
//    BOOL success = [kit runWithEntryFile:filePath windowExtra:nil error:&error];
//    if (!success) {
//#if DEBUG
//        NSLog(@"[%@] %s error. => Error message: %@.", NSStringFromClass(self), __func__, error.localizedDescription ?: @"(null)");
//#endif
//        return nil;
//    }
//
////    UIView *view = [(UIView *)kit.luaWindow subviews].firstObject;
//    UIView *view = (UIView *)kit.luaWindow;
//    objc_setAssociatedObject(view, ArgoUIViewLoaderKitInstanceInstanceKey, kit, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    return view;
    NSError *error = nil;
    UIView *view = [self loadViewFromLuaFilePath:filePath modelKey:modelKey error:&error];
    return view;
}
+ (nullable UIView *)loadViewFromLuaFilePath:(NSString *)filePath
                                    modelKey:(nonnull NSString *)modelKey
                                       error:(NSError * _Nullable __autoreleasing * _Nullable)error{
    ArgoUIViewLoaderKitInstance *kit = [self getInstance];
    kit.modelKey = modelKey;
//    NSError *error = nil;
    BOOL success = [kit runWithEntryFile:filePath windowExtra:nil error:error];
    if (!success) {
#if DEBUG
        NSLog(@"[%@] %s error. => Error message: %@.", NSStringFromClass(self), __func__, (*error).localizedDescription ?: @"(null)");
#endif
        return nil;
    }

//    UIView *view = [(UIView *)kit.luaWindow subviews].firstObject;
    UIView *view = (UIView *)kit.luaWindow;
    objc_setAssociatedObject(view, ArgoUIViewLoaderKitInstanceInstanceKey, kit, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return view;
}

+ (void)dataUpdatedCallbackForView:(UIView *)view callback:(ArgoUIViewLoaderCallback)callback {
    ArgoUIViewLoaderKitInstance *kit = objc_getAssociatedObject(view, ArgoUIViewLoaderKitInstanceInstanceKey);
    kit.inner_dataBinding.callback = callback;
}

+ (void)updateData:(NSObject *)data forView:(UIView *)view autoWire:(BOOL)autoWire {
//    ArgoUIViewLoaderKitInstance *kit = objc_getAssociatedObject(view, ArgoUIViewLoaderKitInstanceInstanceKey);
//    NSParameterAssert(kit);
//    if (!kit) return;
//    NSString *key = kit.modelKey;
//    NSParameterAssert(key);
//    if (!key) return;
//
//    NSObject<ArgoListenerProtocol> *model = nil;
//    if (autoWire) {
//        model = [MLNUIModelHandler autoWireData:data model:nil extra:nil modelKey:key luaCore:kit.luaCore];
//    } else {
//        model = [self convertToObservableObject:data];
//    }
//    kit.observableData = (ArgoObservableMap *)model;
//    [kit.inner_dataBinding bindData:model forKey:key];
//
    NSError *error = nil;
    [self updateData:data forView:view autoWire:autoWire error:&error];
}

+ (void)updateData:(NSObject *)data
           forView:(UIView *)view
          autoWire:(BOOL)autoWire
             error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    ArgoUIViewLoaderKitInstance *kit = objc_getAssociatedObject(view, ArgoUIViewLoaderKitInstanceInstanceKey);
    NSParameterAssert(kit);
    if (!kit) {
        if(error){
            *error = [NSError errorWithDomain:@"com.argoui.error" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"loaderkit instance is nil"}];
            [[MLNUIKitInstanceHandlersManager defaultManager].errorHandler instance:[ArgoUIViewLoaderKitInstance kitInstance] error:@"loaderkit instance is nil"];
        }
        return;
    }
    NSString *key = kit.modelKey;
    NSParameterAssert(key);
    if (!key) {
        if(error){
            *error = [NSError errorWithDomain:@"com.argoui.error" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"loader kit modelkey is nil"}];
        }
        [[MLNUIKitInstanceHandlersManager defaultManager].errorHandler instance:kit error:@"data formate is not Array or dictionary"];
        return;
    }
    NSObject<ArgoListenerProtocol> *model = nil;
    if (autoWire) {
        model = [MLNUIModelHandler autoWireData:data model:nil extra:nil modelKey:key luaCore:kit.luaCore error:error];
    } else {
        model = [self convertToObservableObject:data error:error];
        if (!model) {
            [[MLNUIKitInstanceHandlersManager defaultManager].errorHandler instance:kit error:@"data formate is not Array or dictionary"];
        }
    }
    kit.observableData = (ArgoObservableMap *)model;
    [kit.inner_dataBinding bindData:model forKey:key];
}


+ (ArgoObservableMap *)observableDataForView:(UIView *)view {
    if (!view) return nil;
    ArgoUIViewLoaderKitInstance *kit = objc_getAssociatedObject(view, ArgoUIViewLoaderKitInstanceInstanceKey);
    return kit.observableData;
}

#pragma mark - Private

+ (NSMutableArray<ArgoUIViewLoaderKitInstance *> *)kitQueue {
    if (!_kitQueue) {
        _kitQueue = [NSMutableArray array];
    }
    return _kitQueue;
}

+ (ArgoUIViewLoaderKitInstance *)getInstance {
    ArgoUIViewLoaderKitInstance *instance = [self.kitQueue firstObject];
    if (!instance) {
        instance = [self createInstance];
    } else {
        [self.kitQueue removeObjectAtIndex:0];
    }
    [self preload];
    return instance;
}

+ (void)preload {
    if (_capacity <= self.kitQueue.count) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        ArgoUIViewLoaderKitInstance *instance = [self createInstance];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.kitQueue addObject:instance];
            [self preload];
        });
    });
}

+ (ArgoUIViewLoaderKitInstance *)createInstance {
    return [ArgoUIViewLoaderKitInstance kitInstance];
}

+ (NSObject<ArgoListenerProtocol> *)convertToObservableObject:(id)data
                                                        error:(NSError * _Nullable __autoreleasing * _Nullable)error{
    if ([data isKindOfClass:[NSDictionary class]]) {
        return ObservableFromDictionary(data);
    }
    if ([data isKindOfClass:[NSArray class]]) {
        return ObservableFromArray(data);
    }
    if (error) {
        *error = [NSError errorWithDomain:@"com.argoui.error" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"data formate is not Array or dictionary"}];
    }
    NSParameterAssert(false);
    return nil;
}

static inline ArgoObservableMap *ObservableFromDictionary(NSDictionary *dic) {
    if (!dic) return nil;
    ArgoObservableMap *map = [ArgoObservableMap new];
    [dic enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [map lua_rawPutValue:ObservableFromDictionary(obj) forKey:key];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            [map lua_rawPutValue:ObservableFromArray(obj) forKey:key];
        } else {
            [map lua_rawPutValue:obj forKey:key];
        }
    }];
    return map;
}

static inline ArgoObservableArray *ObservableFromArray(NSArray *array) {
    if (!array) return nil;
    ArgoObservableArray *arr = [ArgoObservableArray new];
    [array enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [arr addObject:ObservableFromDictionary(obj)];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            [arr addObject:ObservableFromArray(obj)];
        } else {
            [arr addObject:obj];
        }
    }];
    return arr;
}

@end


