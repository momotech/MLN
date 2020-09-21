//
//  NSObject+MLNUIDealloctor.m
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/4/30.
//

#import "NSObject+MLNUIDealloctor.h"
@import ObjectiveC;

@interface MLNUIDeallocator : NSObject
@property (readonly, unsafe_unretained) NSObject *owner;
@property (readonly, strong) NSMutableArray<MLNUIDeallocatorCallback> *callbacks;
@end

@implementation MLNUIDeallocator

- (instancetype)initWithOwner:(NSObject*)owner {
    self = [super init];
    if (self) {
        _owner = owner;
        _callbacks = [NSMutableArray new];
    }
    return self;
}

- (void)addCallback:(MLNUIDeallocatorCallback)block {
    if (block)
        [_callbacks addObject:block];
}

- (void)invokeCallbacks {
    NSArray<MLNUIDeallocatorCallback> *blocks = _callbacks;
    _callbacks = nil;
    
    __unsafe_unretained NSObject *owner = _owner;
    for (MLNUIDeallocatorCallback block in blocks) {
        block(owner);
    }
}

- (void)dealloc {
    [self invokeCallbacks];
}
@end

@implementation NSObject (MLNUIDealloctor)

static const void *MLNUIDeallocatorAssociationKey = &MLNUIDeallocatorAssociationKey;
- (void)mlnui_addDeallocationCallback:(MLNUIDeallocatorCallback)block {
    @synchronized (self) {
        @autoreleasepool {
            MLNUIDeallocator *dealloctor = objc_getAssociatedObject(self, MLNUIDeallocatorAssociationKey);
            if (!dealloctor) {
                dealloctor = [[MLNUIDeallocator alloc] initWithOwner:self];
                objc_setAssociatedObject(self, MLNUIDeallocatorAssociationKey, dealloctor, OBJC_ASSOCIATION_RETAIN);
            }
//            [self.class mlnui_swizzleDeallocIfNeeded];
            [dealloctor addCallback:block];
        }
    }
}


#pragma mark - Private
+ (BOOL)mlnui_swizzleDeallocIfNeeded {
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
            MLNUIDeallocator *deallocator = objc_getAssociatedObject(self_deallocating, MLNUIDeallocatorAssociationKey);
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
