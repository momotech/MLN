//
//  NSArray+MLNUIKVO.m
// MLNUI
//
//  Created by Dai Dongpeng on 2020/3/9.
//

#import "NSArray+MLNUIKVO.h"
#import "NSMutableArray+MLNUIKVO.h"
#import "MLNUIExtScope.h"
#import "NSObject+MLNUICore.h"
#import "NSObject+MLNUIKVO.h"
#import "NSObject+MLNUIReflect.h"
#import "ArgoObservableArray.h"
#import "MLNUIHeader.h"

@import ObjectiveC;

@implementation NSArray (MLNUIKVO)

- (NSArray * _Nonnull (^)(MLNUIItemKVOBlock _Nonnull))mlnui_subscribeItem {
    @weakify(self);
     return ^(MLNUIItemKVOBlock block) {
         @strongify(self);
         if (block) {
             [self.mlnui_itemKVOBlocks addObject:block];
         }
         return self;
     };
}

- (NSMutableArray *)mlnui_itemKVOBlocks {
    NSMutableArray *arr = objc_getAssociatedObject(self, _cmd);
    if (!arr) {
        arr = @[].mutableCopy;
        objc_setAssociatedObject(self, _cmd, arr, OBJC_ASSOCIATION_RETAIN);
    }
    return arr;
}

//- (NSArray * _Nonnull (^)(NSString * _Nonnull, MLNUIItemKVOBlock *))mlnui_subscribeItem {
//    return ^(NSString *keyPath, MLNUIItemKVOBlock block){
//        return self;
//    };
//}


- (NSMutableArray *)mlnui_mutalbeCopy {
    NSMutableArray *copy = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(NSObject *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(mlnui_mutalbeCopy)]) {
            [copy addObject:[(NSArray  *)obj mlnui_mutalbeCopy]];
        } else {
            [copy addObject:obj];
        }
    }];
    return copy;
}

- (ArgoObservableArray *)argo_mutableCopy {
    ArgoObservableArray *copy = [ArgoObservableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(NSArray *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(argo_mutableCopy)]) {
            [copy addObject:obj.argo_mutableCopy];
        } else {
            [copy addObject:obj];
        }
    }];
    return copy;
}

- (BOOL)mlnui_is2D {
    NSObject *first = self.firstObject;
    return [first isKindOfClass:[NSArray class]];
}

- (void)mlnui_startKVOIfMutable {
    if ([self isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray *)self mlnui_startKVO];
    }
    
    if (self.mlnui_is2D) {
        [self enumerateObjectsUsingBlock:^(NSMutableArray*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSMutableArray class]]) {
                [obj mlnui_startKVO];
            }
        }];
    }
}

- (void)mlnui_stopKVOIfMutable {
    if ([self isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray *)self mlnui_stopKVO];
    }
    if (self.mlnui_is2D) {
        [self enumerateObjectsUsingBlock:^(NSMutableArray*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSMutableArray class]]) {
                [obj mlnui_stopKVO];
            }
        }];
    }
}

- (NSArray *)mlnui_convertToLuaTableAvailable {
    NSMutableArray *arr = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(NSObject *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject *n = [obj mlnui_convertToLuaObject];
        if (n) {
            [arr addObject:n];
        }
    }];
    return arr.count > 0 ? arr.copy : self.copy;
}

- (instancetype)mlnui_convertToMArray {
#if OCPERF_USE_NEW_DB
    ArgoObservableArray *arr = [ArgoObservableArray array];
#else
    NSMutableArray *arr = [NSMutableArray array];
#endif
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject *n = [obj mlnui_convertToNativeObject];
        if (n) {
            [arr addObject:n];
        }
    }];
    return arr;
}
@end
