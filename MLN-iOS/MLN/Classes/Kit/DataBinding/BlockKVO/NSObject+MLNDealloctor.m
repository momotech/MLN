//
//  NSObject+MLNDealloctor.m
//  MLN
//
//  Created by Dai Dongpeng on 2020/4/30.
//

#import "NSObject+MLNDealloctor.h"
@import ObjectiveC;

@interface MLNDeallocator : NSObject
@property (readonly, unsafe_unretained) NSObject *owner;
@property (readonly, strong) NSMutableArray<MLNDeallocatorCallback> *callbacks;
@end

@implementation MLNDeallocator

- (instancetype)initWithOwner:(NSObject*)owner {
    self = [super init];
    if (self) {
        _owner = owner;
        _callbacks = [NSMutableArray new];
    }
    return self;
}

- (void)addCallback:(MLNDeallocatorCallback)block {
    if (block)
        [_callbacks addObject:block];
}

- (void)invokeCallbacks {
    NSArray<MLNDeallocatorCallback> *blocks = _callbacks;
    _callbacks = nil;
    
    __unsafe_unretained NSObject *owner = _owner;
    for (MLNDeallocatorCallback block in blocks) {
        block(owner);
    }
}

- (void)dealloc {
    [self invokeCallbacks];
}
@end

@implementation NSObject (MLNDealloctor)

static const void *MLNDeallocatorAssociationKey = &MLNDeallocatorAssociationKey;
- (void)mln_addDeallocationCallback:(MLNDeallocatorCallback)block {
    @synchronized (self) {
        @autoreleasepool {
            MLNDeallocator *dealloctor = objc_getAssociatedObject(self, MLNDeallocatorAssociationKey);
            if (!dealloctor) {
                dealloctor = [[MLNDeallocator alloc] initWithOwner:self];
                objc_setAssociatedObject(self, MLNDeallocatorAssociationKey, dealloctor, OBJC_ASSOCIATION_RETAIN);
            }
            [self.class mln_swizzleDeallocIfNeeded];
            [dealloctor addCallback:block];
        }
    }
}


#pragma mark - Private
+ (BOOL)mln_swizzleDeallocIfNeeded {
    static NSMutableSet *swizzledClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [NSMutableSet new];
    });
    
    @synchronized (self) {
        if ([swizzledClasses containsObject:self]) {
            return NO;
        }
        
        SEL deallocSelector = NSSelectorFromString(@"dealloc");
        Method dealloc = class_getInstanceMethod(self, deallocSelector);
        
        void(*oldIMP)(id, SEL) = (typeof(oldIMP))method_getImplementation(dealloc);
        void(^newIMPBlock)(id) = ^(__unsafe_unretained NSObject *self_deallocating) {
            MLNDeallocator *deallocator = objc_getAssociatedObject(self_deallocating, MLNDeallocatorAssociationKey);
            [deallocator invokeCallbacks];
            oldIMP(self_deallocating, deallocSelector);
        };
        
        IMP newIMP = imp_implementationWithBlock(newIMPBlock);
        class_replaceMethod(self, deallocSelector, newIMP, method_getTypeEncoding(dealloc));
        [swizzledClasses addObject:self];
        return YES;
    }
}
@end
