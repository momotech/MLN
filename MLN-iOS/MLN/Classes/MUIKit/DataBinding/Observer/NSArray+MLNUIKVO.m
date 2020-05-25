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

@import ObjectiveC;

@implementation NSArray (MLNUIKVO)

- (NSArray * _Nonnull (^)(MLNUIItemKVOBlock _Nonnull))mln_subscribeItem {
    @weakify(self);
     return ^(MLNUIItemKVOBlock block) {
         @strongify(self);
         if (block) {
             [self.mln_itemKVOBlocks addObject:block];
         }
         return self;
     };
}

- (NSMutableArray *)mln_itemKVOBlocks {
    NSMutableArray *arr = objc_getAssociatedObject(self, _cmd);
    if (!arr) {
        arr = @[].mutableCopy;
        objc_setAssociatedObject(self, _cmd, arr, OBJC_ASSOCIATION_RETAIN);
    }
    return arr;
}

//- (NSArray * _Nonnull (^)(NSString * _Nonnull, MLNUIItemKVOBlock *))mln_subscribeItem {
//    return ^(NSString *keyPath, MLNUIItemKVOBlock block){
//        return self;
//    };
//}


- (NSMutableArray *)mln_mutalbeCopy {
    NSMutableArray *copy = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(NSObject *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(mln_mutalbeCopy)]) {
            [copy addObject:[(NSArray  *)obj mln_mutalbeCopy]];
        } else {
            [copy addObject:obj];
        }
    }];
    return copy;
}

- (BOOL)mln_is2D {
    NSObject *first = self.firstObject;
    return [first isKindOfClass:[NSArray class]];
}

- (void)mln_startKVOIfMutable {
    if ([self isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray *)self mln_startKVO];
    }
    
    if (self.mln_is2D) {
        [self enumerateObjectsUsingBlock:^(NSMutableArray*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSMutableArray class]]) {
                [obj mln_startKVO];
            }
        }];
    }
}

- (void)mln_stopKVOIfMutable {
    if ([self isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray *)self mln_stopKVO];
    }
    if (self.mln_is2D) {
        [self enumerateObjectsUsingBlock:^(NSMutableArray*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSMutableArray class]]) {
                [obj mln_stopKVO];
            }
        }];
    }
}

- (NSArray *)mln_convertToLuaTableAvailable {
    NSMutableArray *arr = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(NSObject *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject *n = [obj mln_convertToLuaObject];
        if (n) {
            [arr addObject:n];
        }
    }];
    return arr.count > 0 ? arr.copy : self.copy;
}

- (instancetype)mln_convertToMArray {
    NSMutableArray *arr = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject *n = [obj mln_convertToNativeObject];
        if (n) {
            [arr addObject:n];
        }
    }];
    return arr;
}
@end
