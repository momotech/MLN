//
//  ArgoObserableObject.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/25.
//

#import "ArgoObserableObject.h"
#import "MLNUIBlockObserver.h"
#import "MLNUIExtScope.h"
#import "ArgoObservableArray.h"

static NSString *const kArgoListenerArrayPlaceHolder = @"ARGO_PH";


@interface ArgoObserverWrapper : NSObject
@property (nonatomic, assign) NSInteger obID;
@property (nonatomic, copy) ArgoBlockChange block;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, unsafe_unretained) ArgoObserableObject *observedObject;

@property (nonatomic, assign, getter=isCanceled) BOOL cancel;
@end

@implementation ArgoObserverWrapper
+ (instancetype)wrapperWithID:(NSInteger)obID block:(ArgoBlockChange)block keyPath:(NSString *)keyPath key:(NSString *)key {
    ArgoObserverWrapper *wrapper = [ArgoObserverWrapper new];
    wrapper.obID = obID;
    wrapper.block = block;
    wrapper.keyPath = keyPath;
    wrapper.key = key;
    return wrapper;
}
@end

@interface ArgoObserverToken : NSObject
@property (nonatomic, strong) NSArray <ArgoObserverWrapper *> *observers;
@end

@implementation ArgoObserverToken
- (void)removeObserver {
    for (ArgoObserverWrapper *wrap in self.observers) {
        if (!wrap.isCanceled) {
            [wrap.observedObject removeObserverWrapper:wrap];
        }
    }
}
@end


@interface ArgoObserableObject()
@property (nonatomic, strong) NSMutableArray <ArgoObserverWrapper *> *observers;
@property (nonatomic, strong) NSMutableArray <ArgoDeallocCallback> *deallocCallbacks;
//@property (nonatomic, strong) NSMutableArray <ArgoKVOBlock> *callbacks;
@end

@implementation ArgoObserableObject

//- (ArgoObserableObject * _Nonnull (^)(NSString * _Nonnull, ArgoKVOBlock _Nonnull))watch {
//    @weakify(self);
//    return ^ArgoObserableObject*(NSString * _Nonnull keyPath, ArgoKVOBlock _Nonnull callback) {
//        @strongify(self);
//        if (self && callback) {
//
//        }
//        return self;
//    };
//}

- (NSObject *)get:(NSString *)key {
    return nil;
}

- (void)put:(NSString *)key value:(NSObject *)value {
}

- (void)addObserverWithChangeBlock:(ArgoBlockChange)block forKeyPath:(NSString *)keyPath {
    NSAssert(keyPath && block, @"should not be nil");
//    if ([keyPath isEqualToString:kArgoListenerArrayPlaceHolder]) { // array
//
//    } else {
//
//    }
    static NSInteger oid = 1;
    NSArray *paths = [keyPath componentsSeparatedByString:@"."];
    ArgoObserableObject *object = self;
    for (int i = 0; i < paths.count; i++) {
        NSString *key = paths[i];
        ArgoObserverWrapper *wrapper = [ArgoObserverWrapper wrapperWithID:oid++ block:block keyPath:keyPath key:key];
        [object addObserverWrapper:wrapper];
        object = (ArgoObserableObject *)[object get:key];
    }
    
    ArgoObservableArray *array = (ArgoObservableArray *)object;
    if ([array isKindOfClass:[ArgoObservableArray class]]) {
        ArgoObserverWrapper *wrapper = [ArgoObserverWrapper wrapperWithID:oid++ block:block keyPath:keyPath key:kArgoListenerArrayPlaceHolder];
        [array addObserverWrapper:wrapper];
//        if (array.proxy.count && [array.proxy.firstObject isKindOfClass:[ArgoObservableArray class]]) {
//
//        }
    }
}

- (void)addObserverWrapper:(ArgoObserverWrapper *)wrapper {
    [self.observers addObject:wrapper];
}

- (void)removeObserverWrapper:(ArgoObserverWrapper *)wrapper {
    if (wrapper) {
        [self.observers removeObject:wrapper];
    }
}

- (void)addDeallocCallback:(ArgoDeallocCallback)callback {
    if (callback) {
        [self.deallocCallbacks addObject:callback];
    }
}

- (void)notifySettingWithKey:(NSString *)key old:(NSObject *)oldV new:(NSObject *)newV {
    for (MLNUIBlockObserver *ob in _observers.copy) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:@(NSKeyValueChangeSetting) forKey:NSKeyValueChangeKindKey];
        if (newV) {
            [info setObject:newV forKey:NSKeyValueChangeNewKey];
        }
        [ob notifyKeyPath:key ofObject:self change:info];
    }
}

#pragma mark -

- (NSMutableArray *)observers {
    if (!_observers) {
        _observers = [NSMutableArray array];
    }
    return _observers;
}


/*
- (NSMutableArray<ArgoDeallocCallback> *)deallocCallbacks {
    if (!_deallocCallbacks) {
        _deallocCallbacks = [NSMutableArray array];
    }
    return _deallocCallbacks;
}

- (void)dealloc {
    for (ArgoDeallocCallback block in _deallocCallbacks) {
        block(self);
    }
}
*/
@end

