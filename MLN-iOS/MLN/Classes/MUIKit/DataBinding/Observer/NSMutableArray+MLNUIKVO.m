//
//  NSMutableArray+MLNUIKVO.m
// MLNUI
//
//  Created by Dai Dongpeng on 2020/3/5.
//

#import "NSMutableArray+MLNUIKVO.h"
#import <objc/runtime.h>
#import "NSObject+MLNUISwizzle.h"

@interface NSObject (MLNUIKVOListener)
@property (nonatomic, strong) Class mlnkvo_originClass;
@property (nonatomic, assign) BOOL mlnkvo_isObervering;
@end

@implementation NSObject (MLNUIKVOListener)

- (Class)mlnkvo_originClass {
    return objc_getAssociatedObject(self, @selector(mlnkvo_originClass));
}

- (void)setMlnkvo_originClass:(Class)mlnkvo_originClass {
    objc_setAssociatedObject(self, @selector(mlnkvo_originClass), mlnkvo_originClass, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)mlnkvo_isObervering {
    return [objc_getAssociatedObject(self, @selector(mlnkvo_isObervering)) boolValue];
}

- (void)setMlnkvo_isObervering:(BOOL)mlnkvo_isObervering {
    objc_setAssociatedObject(self, @selector(mlnkvo_isObervering), @(mlnkvo_isObervering), OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation NSMutableArray (MLNUIKVO)

//- (void)mlnui_notifyAllObserver:(NSKeyValueChange)type new:(NSMutableArray *)new old:(NSMutableArray *)old {
//    NSMutableArray<MLNUIKVOArrayHandler> *obs = objc_getAssociatedObject(self, kMLNUIKVOArrayHandlers);
//    if (obs && obs.count > 0) {
//        for (MLNUIKVOArrayHandler handler in obs) {
//            handler(type, new, old);
//        }
//    }
//}

- (void)mlnui_notifyAllObserver:(NSKeyValueChange)type indexSet:(NSIndexSet *)indexSet newValue:(id)newValue oldValue:(id)oldValue {
    NSArray<MLNUIKVOArrayHandler> *obs;
    @synchronized (self) {
        obs = [self mlnui_observerHandlersCreateIfNeeded:NO].copy;
    }
    if (obs && obs.count > 0) {
        NSMutableDictionary *change = @{}.mutableCopy;
        [change setValue:@(type) forKey:NSKeyValueChangeKindKey];
        [change setValue:indexSet forKey:NSKeyValueChangeIndexesKey];
        [change setValue:newValue forKey:NSKeyValueChangeNewKey];
        [change setValue:oldValue forKey:NSKeyValueChangeOldKey];
        for (MLNUIKVOArrayHandler handler in obs) {
            handler(self, change);
        }
    }
}

//- (NSMutableArray * _Nonnull (^)(MLNUIKVOSubcribeArray _Nonnull))mlnui_subscribeArray {
//    __weak __typeof(self)weakSelf = self;
//    return ^(MLNUIKVOSubcribeArray block) {
//        __strong __typeof(weakSelf)self = weakSelf;
//        [self mlnui_addObserverHandler:^(NSMutableArray * _Nonnull array, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
//            block(change);
//        }];
//        return self;
//    };
//}

- (void)mlnui_addObserverHandler:(MLNUIKVOArrayHandler)handler {
    @synchronized (self) {
        NSMutableArray<MLNUIKVOArrayHandler> *obs = [self mlnui_observerHandlersCreateIfNeeded:YES];
        if (![obs containsObject:handler]) {
            [obs addObject:handler];
        }
    }
}

- (void)mlnui_removeObserverHandler:(MLNUIKVOArrayHandler)handler {
    if (handler) {
        @synchronized (self) {
            NSMutableArray *obs = [self mlnui_observerHandlersCreateIfNeeded:NO];
            [obs removeObject:handler];
        }
    }
}

- (void)mlnui_clearObserverHandlers {
    @synchronized (self) {
        NSMutableArray *obs = [self mlnui_observerHandlersCreateIfNeeded:NO];
        [obs removeAllObjects];
    }
}

static const void *kMLNUIKVOArrayHandlers = &kMLNUIKVOArrayHandlers;
- (NSMutableArray<MLNUIKVOArrayHandler> *)mlnui_observerHandlersCreateIfNeeded:(BOOL)shouldCreate {
    NSMutableArray *obs = objc_getAssociatedObject(self, kMLNUIKVOArrayHandlers);
    if (!obs && shouldCreate) {
        obs = [NSMutableArray array];
        objc_setAssociatedObject(self, kMLNUIKVOArrayHandlers, obs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obs;
}

static NSString *kMLNUIKVO = @"-MLNUIKVO";
NS_INLINE  Class MLNUICreateSubClass(Class class, NSString *subName) {
    Class subclass = objc_allocateClassPair(class, [subName UTF8String], 0);
    objc_registerClassPair(subclass);
    return subclass;
}

// 只对当前对象进行KVO
- (void)mlnui_startKVO {
    Class class = object_getClass(self);
    NSString *className = NSStringFromClass(class);
    BOOL isStart = [className containsString:kMLNUIKVO];
    if (!isStart) {
        self.mlnkvo_originClass = class;
        NSString *subName = [className stringByAppendingString:kMLNUIKVO];
        Class subClass = objc_getClass(subName.UTF8String);
        if (!subClass) {
            subClass = MLNUICreateSubClass(class, subName);
            [NSMutableArray mlnkvo_swizzleWithClass:subClass];
        };
        object_setClass(self, subClass);
    }
}

- (void)mlnui_stopKVO {
    Class cls = object_getClass(self);
    BOOL isStart = [NSStringFromClass(cls) containsString:kMLNUIKVO];
    Class originClass = self.mlnkvo_originClass;
    if (isStart && originClass) {
        object_setClass(self, originClass);
        self.mlnkvo_originClass = nil;
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#define GetIMP() \
Class super = class_getSuperclass(object_getClass(self)); \
Method m = class_getInstanceMethod(super, origin); \
IMP imp = method_getImplementation(m)

#define CallIMP(A) \
BOOL isOberversing = self.mlnkvo_isObervering; \
if (!isOberversing) { \
    self.mlnkvo_isObervering = YES; \
} \
GetIMP(); \
A; \

#define AfterIMP(A)\
if (!isOberversing) { \
    self.mlnkvo_isObervering = NO; \
    A; \
}

+ (void)mlnkvo_swizzleWithClass:(Class)cls {
/****************************************
according to: https://developer.apple.com/documentation/foundation/nsmutablearray#//apple_ref/doc/uid/TP40003688
shold override five primitive methods
    insertObject:atIndex:
    removeObjectAtIndex:
    addObject:
    removeLastObject
    replaceObjectAtIndex:withObject:
 ************************************************/
    dispatch_block_t placeholderBlock = ^{};
    SEL origin, swizzle;
    
    origin = @selector(insertObject:atIndex:);
    swizzle = @selector(mlnkvo_insertObject:atIndex:);
    [cls mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self, id object, NSUInteger index) {
        id oldValue;
        if (index < self.count) {
            oldValue = [self objectAtIndex:index];
        }
        // call real imp
        GetIMP();
        ((void(*)(id,SEL,id,NSUInteger))imp)(self, origin, object,index);
        // call observer
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
        [self mlnui_notifyAllObserver:NSKeyValueChangeInsertion indexSet:set newValue:object oldValue:oldValue];
    } forceAddOriginImpBlock:placeholderBlock];
    
    origin = @selector(removeObjectAtIndex:);
    swizzle = @selector(mlnkvo_removeObjectAtIndex:);
    [cls mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self, NSUInteger index) {
        id oldValue;
        if (index < self.count) {
            oldValue = [self objectAtIndex:index];
        }
        
        GetIMP();
        ((void(*)(id,SEL,NSUInteger))imp)(self, origin, index);
        
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
        [self mlnui_notifyAllObserver:NSKeyValueChangeRemoval indexSet:set newValue:nil oldValue:oldValue];
    } forceAddOriginImpBlock:placeholderBlock];
    
    // iOS13: addobject: will call insertObject:atIndex:
//    origin = @selector(addObject:);
//    swizzle = @selector(mlnkvo_addObject:);
//    [cls mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self, id object) {
//        // call real imp
//        GetIMP();
//        ((void(*)(id,SEL,id))imp)(self, origin, object);
//        // call observer
//        NSIndexSet *set = [NSIndexSet indexSetWithIndex:self.count - 1];
//        [self mlnui_notifyAllObserver:NSKeyValueChangeInsertion indexSet:set newValue:object oldValue:nil];
//    } forceAddOriginImpBlock:placeholderBlock];
    
//    origin = @selector(removeLastObject);
//    swizzle = @selector(mlnkvo_removeLastObject);
//    [cls mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self) {
//        NSIndexSet *set = self.count > 0 ? [NSIndexSet indexSetWithIndex:self.count - 1] : nil;
//        id oldValue = self.lastObject;
//        // call real imp
//        GetIMP();
//        ((void(*)(id,SEL))imp)(self, origin);
//        // call observer
//        [self mlnui_notifyAllObserver:NSKeyValueChangeInsertion indexSet:set newValue:nil oldValue:oldValue];
//    } forceAddOriginImpBlock:placeholderBlock];
    
    origin = @selector(replaceObjectAtIndex:withObject:);
    swizzle = @selector(mlnkvo_replaceObjectAtIndex:withObject:);
    [cls mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self, NSUInteger index, id object) {
        id oldValue;
        if (index < self.count) {
            oldValue = [self objectAtIndex:index];
        }
        GetIMP();
//        CallIMP(
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
        ((void(*)(id,SEL,NSUInteger,id))imp)(self, origin,index,object);
//                )
//        AfterIMP(
        [self mlnui_notifyAllObserver:NSKeyValueChangeReplacement indexSet:set newValue:object oldValue:oldValue];
//                 )
    } forceAddOriginImpBlock:placeholderBlock];
    
    origin = @selector(setObject:atIndexedSubscript:);
    swizzle = @selector(mlnkvo_setObject:atIndexedSubscript:);
    [cls mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self, id object, NSUInteger index) {
        id oldValue;
        if (index < self.count) {
            oldValue = [self objectAtIndex:index];
        }
        GetIMP();
//        CallIMP(
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
        ((void(*)(id,SEL,id,NSUInteger))imp)(self, origin,object,index);
//                )
//        AfterIMP(
        [self mlnui_notifyAllObserver:NSKeyValueChangeReplacement indexSet:set newValue:object oldValue:oldValue];
//                 )
    } forceAddOriginImpBlock:placeholderBlock];
    
    origin = @selector(addObjectsFromArray:);
    swizzle = @selector(mlnkvo_addObjectsFromArray:);
    [cls mlnui_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self, NSArray* objects) {
        // call real imp
        GetIMP();
        ((void(*)(id,SEL,id))imp)(self, origin, objects);
        // call observer
        if (objects && objects.count > 0 && self.count >= objects.count) {
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.count - objects.count, objects.count)];
            [self mlnui_notifyAllObserver:NSKeyValueChangeInsertion indexSet:set newValue:objects oldValue:nil];
        }
    } forceAddOriginImpBlock:placeholderBlock];
}

#pragma clang diagnostic pop

@end

