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
@property (nonatomic, strong) Class mln_originClass;
@end

@implementation NSObject (MLNKVOListener)

- (Class)mln_originClass {
    return objc_getAssociatedObject(self, @selector(mln_originClass));
}

- (void)setMln_originClass:(Class)mln_originClass {
    objc_setAssociatedObject(self, @selector(mln_originClass), mln_originClass, OBJC_ASSOCIATION_RETAIN);
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

- (void)mln_notifyAllObserver:(NSKeyValueChange)type indexSet:(NSIndexSet *)indexSet {
    NSMutableArray<MLNKVOArrayHandler> *obs = objc_getAssociatedObject(self, kMLNKVOArrayHandlers);
    if (obs && obs.count > 0) {
        NSMutableDictionary *change = @{}.mutableCopy;
        [change setValue:@(type) forKey:NSKeyValueChangeKindKey];
        [change setValue:indexSet forKey:NSKeyValueChangeIndexesKey];
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
        self.mln_originClass = class;
        NSString *subName = [className stringByAppendingString:kMLNKVO];
        Class subClass = objc_getClass(subName.UTF8String);
        if (!subClass) {
            subClass = MLNCreateSubClass(class, subName);
            [NSMutableArray swizzleWithClass:subClass];
        };
        object_setClass(self, subClass);
    }
}

- (void)mln_stopKVO {
    Class cls = object_getClass(self);
    BOOL isStart = [NSStringFromClass(cls) containsString:kMLNKVO];
    Class originClass = self.mln_originClass;
    if (isStart && self.mln_originClass) {
        object_setClass(self, originClass);
    }
}

@end

@implementation NSMutableArray (MLNKVOListener)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

//+ (void)mlnkvo_addNecessaryMethodForClass:(Class)cls {
//    SEL sel_arr[] = {
//        @selector(insertObject:atIndex:)
//    };
//    IMP imp = imp_implementationWithBlock(^{});
//    for (int i = 0; i < sizeof(sel_arr) / sizeof(SEL); i++) {
//        SEL sel = sel_arr[i];
//        Method originMethod = class_getInstanceMethod(cls, sel);
//    }
//}

+ (void)swizzleWithClass:(Class)cls {
    SEL origin = @selector(insertObject:atIndex:);
    SEL swizzle = @selector(mlnkvo_insertObject:atIndex:);
    dispatch_block_t placeholderBlock = ^{};

    [cls mln_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self, id object, NSUInteger index) {
        // call real imp
        Class super = class_getSuperclass(object_getClass(self));
        Method m = class_getInstanceMethod(super, origin);
        IMP imp = method_getImplementation(m);
        ((void(*)(id,SEL,id,NSUInteger))imp)(self, origin, object,index);
        // call observer
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:self.count];
        [self mln_notifyAllObserver:NSKeyValueChangeInsertion indexSet:set];
    } forceAddOriginImpBlock:placeholderBlock];
    
//    origin = @selector(addObject:);
//    swizzle = @selector(mlnkvo_addObject:);
//    [cls mln_swizzleInstanceSelector:origin withNewSelector:swizzle newImpBlock:^(NSMutableArray *self, id object) {
//        // call real imp
//        Class super = class_getSuperclass(object_getClass(self));
//        Method m = class_getInstanceMethod(super, origin);
//        IMP imp = method_getImplementation(m);
//        ((void(*)(id,SEL,id))imp)(self, origin, object);
//        // call observer
//        NSIndexSet *set = [NSIndexSet indexSetWithIndex:self.count];
//        [self mln_notifyAllObserver:NSKeyValueChangeInsertion indexSet:set];
//    } forceAddOriginImpBlock:placeholderBlock];
}

#pragma clang diagnostic pop

+ (void)swizzleArray:(NSMutableArray *)array {
    
}

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
