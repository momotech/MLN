//
//  NSArray+MLNKVO.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/9.
//

#import "NSArray+MLNKVO.h"
@import ObjectiveC;

@implementation NSArray (MLNKVO)

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
@end
