//
//  ArgoUIViewLoader.m
//  ArgoUI
//
//  Created by xindong on 2021/1/25.
//

#import "ArgoUIViewLoader.h"
#import <objc/message.h>

#if __has_include(<ArgoUIKit.h>)
#import <MLNUILuaBundle.h>
#import <ArgoDataBinding.h>
#import <MLNUIKitInstance.h>
#import <MLNUIModelHandler.h>
#import <ArgoObservableMap.h>
#import <ArgoObservableArray.h>
#import <NSObject+ArgoListener.h>
#import <ArgoViewController.h>
#else
#import "MLNUILuaBundle.h"
#import "ArgoDataBinding.h"
#import "MLNUIKitInstance.h"
#import "MLNUIModelHandler.h"
#import "ArgoObservableMap.h"
#import "ArgoObservableArray.h"
#import "NSObject+ArgoListener.h"
#import "ArgoViewController.h"
#endif

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

@interface ArgoUIViewLoaderKit: MLNUIKitInstance
+ (ArgoUIViewLoaderKit *)kit;
@property (nonatomic, strong) ArgoUIViewLoaderDataBinding *inner_dataBinding;
@property (nonatomic, strong) NSString *modelKey;
@end

@interface ArgoUIViewLoaderController : UIViewController<MLNUIViewControllerProtocol>
@property (nonatomic, weak) ArgoUIViewLoaderKit *instance;
@end

@implementation ArgoUIViewLoaderKit {
    UIViewController *_innerController;
}

+ (ArgoUIViewLoaderKit *)kit {
    static UIView *rootView = nil;
    if (!rootView) {
        rootView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    }
    ArgoUIViewLoaderController *controller = [ArgoUIViewLoaderController new];
    ArgoUIViewLoaderKit *instance = [[ArgoUIViewLoaderKit alloc] initWithLuaBundle:[MLNUILuaBundle mainBundle] rootView:rootView viewController:controller];
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
static NSMutableArray<ArgoUIViewLoaderKit *> *_kitQueue = nil;
static const char *ArgoUIViewLoaderKitInstanceKey = "ArgoUIViewLoaderKitInstanceKey";

@interface ArgoUIViewLoader ()

@property (nonatomic, readonly, class) NSMutableArray<ArgoUIViewLoaderKit *> *kitQueue;

@end

@implementation ArgoUIViewLoader

#pragma mark - Public

+ (void)preload:(NSUInteger)capacity {
    _capacity = capacity;
    [self preload];
}

+ (nullable UIView *)loadViewFromLuaFilePath:(NSString *)filePath modelKey:(nonnull NSString *)modelKey {
    ArgoUIViewLoaderKit *kit = [self getInstance];
    kit.modelKey = modelKey;
    
    NSError *error = nil;
    BOOL success = [kit runWithEntryFile:filePath windowExtra:nil error:&error];
    if (!success) {
#if DEBUG
        NSLog(@"[%@] %s error. => Error message: %@.", NSStringFromClass(self), __func__, error.localizedDescription ?: @"(null)");
#endif
        return nil;
    }
    
    UIView *view = [(UIView *)kit.luaWindow subviews].firstObject;
    objc_setAssociatedObject(view, ArgoUIViewLoaderKitInstanceKey, kit, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return view;
}

+ (void)dataUpdatedCallbackForView:(UIView *)view callback:(ArgoUIViewLoaderCallback)callback {
    ArgoUIViewLoaderKit *kit = objc_getAssociatedObject(view, ArgoUIViewLoaderKitInstanceKey);
    kit.inner_dataBinding.callback = callback;
}

+ (void)updateData:(NSObject *)data forView:(nonnull UIView *)view autoWire:(BOOL)autoWire {
    ArgoUIViewLoaderKit *kit = objc_getAssociatedObject(view, ArgoUIViewLoaderKitInstanceKey);
    NSParameterAssert(kit);
    if (!kit) return;
    NSString *key = kit.modelKey;
    NSParameterAssert(key);
    if (!key) return;
    if (autoWire) {
        NSObject<ArgoListenerProtocol> *model = [MLNUIModelHandler autoWireData:data model:nil extra:nil modelKey:key luaCore:kit.luaCore];
        [kit.inner_dataBinding bindData:model forKey:key];
    } else {
        NSObject<ArgoListenerProtocol> *model = [self convertToObservableObject:data];
        [kit.inner_dataBinding bindData:model forKey:key];
    }
}

#pragma mark - Private

+ (NSMutableArray<ArgoUIViewLoaderKit *> *)kitQueue {
    if (!_kitQueue) {
        _kitQueue = [NSMutableArray array];
    }
    return _kitQueue;
}

+ (ArgoUIViewLoaderKit *)getInstance {
    ArgoUIViewLoaderKit *instance = [self.kitQueue firstObject];
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
        ArgoUIViewLoaderKit *instance = [self createInstance];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.kitQueue addObject:instance];
            [self preload];
        });
    });
}

+ (ArgoUIViewLoaderKit *)createInstance {
    return [ArgoUIViewLoaderKit kit];
}

+ (NSObject<ArgoListenerProtocol> *)convertToObservableObject:(id)data {
    if ([data isKindOfClass:[NSDictionary class]]) {
        return ObservableFromDictionary(data);
    }
    if ([data isKindOfClass:[NSArray class]]) {
        return ObservableFromArray(data);
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


