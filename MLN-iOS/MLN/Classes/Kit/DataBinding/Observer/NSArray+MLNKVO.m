//
//  NSArray+MLNKVO.m
// MLN
//
//  Created by Dai Dongpeng on 2020/3/9.
//

#import "NSArray+MLNKVO.h"
#import "NSMutableArray+MLNKVO.h"
@import ObjectiveC;

@implementation NSArray (MLNKVO)

- (NSArray * _Nonnull (^)(MLNItemKVOBlock _Nonnull))mln_subscribeItem {
    __weak __typeof(self)weakSelf = self;
     return ^(MLNItemKVOBlock block) {
         __strong __typeof(weakSelf)self = weakSelf;
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

//- (NSArray * _Nonnull (^)(NSString * _Nonnull, MLNItemKVOBlock *))mln_subscribeItem {
//    return ^(NSString *keyPath, MLNItemKVOBlock block){
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

- (void)mln_startKVOIfMutableble {
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


@end
