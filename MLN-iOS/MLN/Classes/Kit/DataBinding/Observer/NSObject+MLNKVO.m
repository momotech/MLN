//
//  NSObject+MLNKVO.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/19.
//

#import "NSObject+MLNKVO.h"
#import "KVOController.h"
#import "MLNKVOObserver.h"
@import ObjectiveC;

@implementation NSObject (MLNKVO)

- (NSString * _Nonnull (^)(NSArray * _Nonnull, NSUInteger, NSUInteger))mln_resueIdBlock {
    return objc_getAssociatedObject(self, @selector(mln_resueIdBlock));
}

- (void)setMln_resueIdBlock:(NSString * _Nonnull (^)(NSArray * _Nonnull, NSUInteger, NSUInteger))mln_resueIdBlock {
    objc_setAssociatedObject(self, @selector(mln_resueIdBlock), mln_resueIdBlock, OBJC_ASSOCIATION_COPY);
}

- (NSUInteger (^)(NSArray * _Nonnull, NSUInteger, NSUInteger))mln_heightBlock {
    return objc_getAssociatedObject(self, @selector(mln_heightBlock));
}

- (void)setMln_heightBlock:(NSUInteger (^)(NSArray * _Nonnull, NSUInteger, NSUInteger))mln_heightBlock {
    objc_setAssociatedObject(self, @selector(mln_heightBlock), mln_heightBlock, OBJC_ASSOCIATION_COPY);
}

- (CGSize (^)(NSArray * _Nonnull, NSUInteger, NSUInteger))mln_sizeBlock {
    return objc_getAssociatedObject(self, @selector(mln_sizeBlock));
}

- (void)setMln_sizeBlock:(CGSize (^)(NSArray * _Nonnull, NSUInteger, NSUInteger))mln_sizeBlock {
    objc_setAssociatedObject(self, @selector(mln_sizeBlock), mln_sizeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSObject * _Nonnull (^)(NSString * _Nonnull, MLNKVOBlock _Nonnull))mln_subscribe {
    __weak typeof (self) weakSelf = self;
    return ^(NSString *keyPath, MLNKVOBlock block){
        __strong typeof (weakSelf) self = weakSelf;
        if (self && block) {
//            [self.KVOControllerNonRetaining observe:self keyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//                id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
//                id newValue = [change objectForKey:NSKeyValueChangeNewKey];
//                block(oldValue, newValue);
//            }];
            
            MLNKVOObserver *ob = [[MLNKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
                id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
                id newValue = [change objectForKey:NSKeyValueChangeNewKey];
                block(oldValue, newValue);
            } keyPath:keyPath];
            
            [self.KVOControllerNonRetaining observe:self keyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                [ob mln_observeValueForKeyPath:keyPath ofObject:object change:change];
            }];

        }
        return self;
    };
}

@end
