//
//  NSMutableArray+MLNKVO.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/5.
//

#import "NSMutableArray+MLNKVO.h"
#import <objc/runtime.h>

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

@end


@implementation NSMutableArray (MLNListener)

+ (void)load {
    Method origMethod1 = class_getInstanceMethod([self class], @selector(addObject:));
    Method swizzledMethod1 = class_getInstanceMethod([self class], @selector(mln_listener_addObject:));
    method_exchangeImplementations(origMethod1, swizzledMethod1);
    
    origMethod1 = class_getInstanceMethod([self class], @selector(insertObject:atIndex:));
    swizzledMethod1 = class_getInstanceMethod([self class], @selector(mln_listener_insertObject:atIndex:));
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

