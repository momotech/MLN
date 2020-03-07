//
//  NSMutableArray+MLNKVO.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/5.
//

#import "NSMutableArray+MLNKVO.h"
#import <objc/runtime.h>
#import "NSObject+MLNSwizzle.h"

@interface NSObject (MLNKVOListener)
@property (nonatomic, strong) Class mlnkvo_originClass;
@property (nonatomic, assign) BOOL mlnkvo_isObervering;
@end

@implementation NSObject (MLNKVOListener)

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

@implementation NSMutableArray (MLNKVO)

//- (void)mln_notifyAllObserver:(NSKeyValueChange)type new:(NSMutableArray *)new old:(NSMutableArray *)old {
//    NSMutableArray<MLNKVOArrayHandler> *obs = objc_getAssociatedObject(self, kMLNKVOArrayHandlers);
//    if (obs && obs.count > 0) {
//        for (MLNKVOArrayHandler handler in obs) {
//            handler(type, new, old);
//        }
//    }
//}

- (void)mln_notifyAllObserver:(NSKeyValueChange)type indexSet:(NSIndexSet *)indexSet newValue:(id)newValue oldValue:(id)oldValue {
    NSMutableArray<MLNKVOArrayHandler> *obs = objc_getAssociatedObject(self, kMLNKVOArrayHandlers);
    if (obs && obs.count > 0) {
        NSMutableDictionary *change = @{}.mutableCopy;
        [change setValue:@(type) forKey:NSKeyValueChangeKindKey];
        [change setValue:indexSet forKey:NSKeyValueChangeIndexesKey];
        [change setValue:newValue forKey:NSKeyValueChangeNewKey];
        [change setValue:oldValue forKey:NSKeyValueChangeOldKey];
        for (MLNKVOArrayHandler handler in obs) {
            handler(self, change);
        }
    }
}

- (void)mln_addObserverHandler:(MLNKVOArrayHandler)handler {
    NSMutableArray<MLNKVOArrayHandler> *obs = [self observerHandlers];
    if (![obs containsObject:handler]) {
        [obs addObject:handler];
    }
}

- (void)mln_removeObserverHandler:(MLNKVOArrayHandler)handler {
    if (handler) {
        NSMutableArray *obs = objc_getAssociatedObject(self, kMLNKVOArrayHandlers);
        [obs removeObject:handler];
    }
}

- (void)mln_clearObserverHandlers {
    NSMutableArray *obs = objc_getAssociatedObject(self, kMLNKVOArrayHandlers);
    [obs removeAllObjects];
}

static const void *kMLNKVOArrayHandlers = &kMLNKVOArrayHandlers;
- (NSMutableArray<MLNKVOArrayHandler> *)observerHandlers {
    NSMutableArray *obs = objc_getAssociatedObject(self, kMLNKVOArrayHandlers);
    if (!obs) {
        obs = [NSMutableArray array];
        objc_setAssociatedObject(self, kMLNKVOArrayHandlers, obs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obs;
}

static NSString *kMLNKVO = @"-MLNKVO";
NS_INLINE  Class MLNCreateSubClass(Class class, NSString *subName) {
    Class subclass = objc_allocateClassPair(class, [subName UTF8String], 0);
    objc_registerClassPair(subclass);
    return subclass;
}

// 只对当前对象进行KVO
- (void)mln_startKVO {
    Class class = object_getClass(self);
    NSString *className = NSStringFromClass(class);
    BOOL isStart = [className containsString:kMLNKVO];
    if (!isStart) {
        self.mlnkvo_originClass = class;
        NSString *subName = [className stringByAppendingString:kMLNKVO];
        Class subClass = objc_getClass(subName.UTF8String);
        if (!subClass) {
            subClass = MLNCreateSubClass(class, subName);
            [NSMutableArray mlnkvo_swizzleWithClass:subClass];
        };
        object_setClass(self, subClass);
    }
}

- (void)mln_stopKVO {
    Class cls = object_getClass(self);
    BOOL isStart = [NSStringFromClass(cls) containsString:kMLNKVO];
    Class originClass = self.mlnkvo_originClass;
    if (isStart && originClass) {
        object_setClass(self, originClass);
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
    [cls mln_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self, id object, NSUInteger index) {
        id oldValue;
        if (index < self.count) {
            oldValue = [self objectAtIndex:index];
        }
        // call real imp
        GetIMP();
        ((void(*)(id,SEL,id,NSUInteger))imp)(self, origin, object,index);
        // call observer
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
        [self mln_notifyAllObserver:NSKeyValueChangeInsertion indexSet:set newValue:object oldValue:oldValue];
    } forceAddOriginImpBlock:placeholderBlock];
    
    origin = @selector(removeObjectAtIndex:);
    swizzle = @selector(mlnkvo_removeObjectAtIndex:);
    [cls mln_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self, NSUInteger index) {
        id oldValue;
        if (index < self.count) {
            oldValue = [self objectAtIndex:index];
        }
        
        GetIMP();
        ((void(*)(id,SEL,NSUInteger))imp)(self, origin, index);
        
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
        [self mln_notifyAllObserver:NSKeyValueChangeRemoval indexSet:set newValue:nil oldValue:oldValue];
    } forceAddOriginImpBlock:placeholderBlock];
    
    // iOS13: addobject: will call insertObject:atIndex:
//    origin = @selector(addObject:);
//    swizzle = @selector(mlnkvo_addObject:);
//    [cls mln_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self, id object) {
//        // call real imp
//        GetIMP();
//        ((void(*)(id,SEL,id))imp)(self, origin, object);
//        // call observer
//        NSIndexSet *set = [NSIndexSet indexSetWithIndex:self.count - 1];
//        [self mln_notifyAllObserver:NSKeyValueChangeInsertion indexSet:set newValue:object oldValue:nil];
//    } forceAddOriginImpBlock:placeholderBlock];
    
//    origin = @selector(removeLastObject);
//    swizzle = @selector(mlnkvo_removeLastObject);
//    [cls mln_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self) {
//        NSIndexSet *set = self.count > 0 ? [NSIndexSet indexSetWithIndex:self.count - 1] : nil;
//        id oldValue = self.lastObject;
//        // call real imp
//        GetIMP();
//        ((void(*)(id,SEL))imp)(self, origin);
//        // call observer
//        [self mln_notifyAllObserver:NSKeyValueChangeInsertion indexSet:set newValue:nil oldValue:oldValue];
//    } forceAddOriginImpBlock:placeholderBlock];
    
    origin = @selector(replaceObjectAtIndex:withObject:);
    swizzle = @selector(mlnkvo_replaceObjectAtIndex:withObject:);
    [cls mln_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self, NSUInteger index, id object) {
        id oldValue;
        if (index < self.count) {
            oldValue = [self objectAtIndex:index];
        }
        CallIMP(
                NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
                ((void(*)(id,SEL,NSUInteger,id))imp)(self, origin,index,object)
                )
        AfterIMP(
                 [self mln_notifyAllObserver:NSKeyValueChangeReplacement indexSet:set newValue:object oldValue:oldValue]
                 )

    } forceAddOriginImpBlock:placeholderBlock];
}

#pragma clang diagnostic pop

@end

/*
@implementation NSMutableArray (MLNListener)

+ (void)load {
    
    Class cls = NSClassFromString(@"__NSArrayM");
//    cls = [self class];
    Method origMethod1 = class_getInstanceMethod(cls, @selector(addObject:));
    Method swizzledMethod1 = class_getInstanceMethod([self class], @selector(mln_listener_addObject:));
//    method_exchangeImplementations(origMethod1, swizzledMethod1);
    
    origMethod1 = class_getInstanceMethod(cls, @selector(insertObject:atIndex:));
    swizzledMethod1 = class_getInstanceMethod([self class], @selector(mln_listener_insertObject:atIndex:));
    method_exchangeImplementations(origMethod1, swizzledMethod1);
    
    origMethod1 = class_getInstanceMethod(cls, @selector(setObject:atIndexedSubscript:));
    swizzledMethod1 = class_getInstanceMethod([self class], @selector(mln_listener_setObject:atIndexedSubscript:));
    method_exchangeImplementations(origMethod1, swizzledMethod1);
    
    origMethod1 = class_getInstanceMethod(cls, @selector(setObject:atIndex:));
    swizzledMethod1 = class_getInstanceMethod([self class], @selector(mln_listener_setObject:atIndex:));
    method_exchangeImplementations(origMethod1, swizzledMethod1);
}

- (void)mln_listener_addObject:(id)anObject {
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:self.count];
    [self mln_listener_addObject:anObject];
    [self mln_notifyAllObserver:NSKeyValueChangeInsertion indexSet:set];
}

- (void)mln_listener_insertObject:(id)anObject atIndex:(NSUInteger)index {
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
    [self mln_listener_insertObject:anObject atIndex:index];
    [self mln_notifyAllObserver:NSKeyValueChangeInsertion indexSet:set];
    int cnt = 0;
    NSArray *calls = [NSThread callStackSymbols];
    for (NSString *stack in calls) {
        if ([stack containsString:@"[NSMutableArray(MLNListener) mln_listener_"]) {
            cnt++;
        }
    }
//    NSAssert(cnt < 2, calls.description);
}

- (void)mln_listener_setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:idx];
    [self mln_listener_setObject:obj atIndexedSubscript:idx];
    [self mln_notifyAllObserver:NSKeyValueChangeInsertion indexSet:set];
}

- (void)mln_listener_setObject:(id)obj atIndex:(NSUInteger)idx {
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:idx];
    [self mln_listener_setObject:obj atIndex:idx];
    [self mln_notifyAllObserver:NSKeyValueChangeInsertion indexSet:set];
}

/// -------------------------------- 待实现接口 -----------
//- (void)removeLastObject;
//- (void)removeObjectAtIndex:(NSUInteger)index;
//- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(ObjectType)anObject;
//- (void)addObjectsFromArray:(NSArray<ObjectType> *)otherArray;
//- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
//- (void)removeAllObjects;
//- (void)removeObject:(ObjectType)anObject inRange:(NSRange)range;
//- (void)removeObject:(ObjectType)anObject;
//- (void)removeObjectIdenticalTo:(ObjectType)anObject inRange:(NSRange)range;
//- (void)removeObjectIdenticalTo:(ObjectType)anObject;
//- (void)removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)cnt API_DEPRECATED("Not supported", macos(10.0,10.6), ios(2.0,4.0), watchos(2.0,2.0), tvos(9.0,9.0));
//- (void)removeObjectsInArray:(NSArray<ObjectType> *)otherArray;
//- (void)removeObjectsInRange:(NSRange)range;
//- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ObjectType> *)otherArray range:(NSRange)otherRange;
//- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ObjectType> *)otherArray;
//- (void)setArray:(NSArray<ObjectType> *)otherArray;
//- (void)sortUsingFunction:(NSInteger (NS_NOESCAPE *)(ObjectType,  ObjectType, void * _Nullable))compare context:(nullable void *)context;
//- (void)sortUsingSelector:(SEL)comparator;
//
//- (void)insertObjects:(NSArray<ObjectType> *)objects atIndexes:(NSIndexSet *)indexes;
//- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
//- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray<ObjectType> *)objects;


@end

*/
