//
//  ArgoObservableArray.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#import "ArgoObservableArray.h"
#import "NSObject+ArgoListener.h"
#import "ArgoListenerWrapper.h"

@interface ArgoObservableArray()
@property (nonatomic, strong) NSMutableArray *proxy;
//
@property (nonatomic, strong) NSMutableDictionary *argoListeners;

@end

@implementation ArgoObservableArray

- (NSObject *)get:(NSString *)key {
    return [self objectAtIndex:key.integerValue - 1];
}

- (void)putValue:(NSObject *)value forKey:(NSString *)key {
    [self insertObject:value atIndex:key.integerValue - 1];
}

- (void)notifyWithType:(NSKeyValueChange)type indexSet:(NSIndexSet *)indexSet newValue:(id)newValue oldValue:(id)oldValue {
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    [change setObject:@(type) forKey:NSKeyValueChangeKindKey];
    if (indexSet) {
        [change setObject:indexSet forKey:NSKeyValueChangeIndexesKey];
    }
    if (newValue) {
        [change setObject:newValue forKey:NSKeyValueChangeNewKey];
    }
    if (oldValue) {
        [change setObject:oldValue forKey:NSKeyValueChangeOldKey];
    }
    [self notifyArgoListenerKey:kArgoListenerArrayPlaceHolder Change:change];
}

- (NSMutableDictionary *)argoListeners {
    if (!_argoListeners) {
        _argoListeners = [NSMutableDictionary dictionary];
    }
    return _argoListeners;
}

- (void)dealloc {
//    if (_argoListeners.count) {
//        for (ArgoListenerWrapper *wrap in self.argoListeners) {
//            [wrap cancel];
//        }
//    }
}


#pragma mark - CustomMutableArray
- (instancetype)initWithMutableArray:(NSMutableArray*)array {
    if((self = [super init])) {
        _proxy = array;
    }
    return self;
}

- (instancetype)init {
    return [self initWithMutableArray:[[NSMutableArray alloc] init]];
}

- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt {
    NSMutableArray* arr = [[NSMutableArray alloc] initWithObjects:objects count:cnt];
    return [self initWithMutableArray:arr];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    NSMutableArray* arr = [[NSMutableArray alloc]  initWithCapacity:numItems];
    return [self initWithMutableArray:arr];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSMutableArray* arr = [[NSMutableArray alloc] initWithCoder:aDecoder];
    return [self initWithMutableArray:arr];
}

- (void)encodeWithCoder:(NSCoder *)encoder; {
    [self.proxy encodeWithCoder:encoder];
}

- (BOOL)isEqualToArray:(ArgoObservableArray*)array {
    if (![array isKindOfClass:[ArgoObservableArray class]]) {
        return NO;
    }
    return [self.proxy isEqualToArray:array.proxy];
}

#pragma mark -

- (NSUInteger)count {
    return [self.proxy count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self.proxy objectAtIndex:index];
}

#pragma mark - NSArray subclassing methods, not on Apple's doc but required
- (id)firstObject {
    return self.proxy.firstObject;
}

- (id)lastObject {
    return self.proxy.lastObject;
}

#pragma mark - NSMutableArray subclassing methods

/*
 NSMutableArray defines five primitive methods:
 insertObject:atIndex:
 removeObjectAtIndex:
 addObject:
 removeLastObject
 replaceObjectAtIndex:withObject:
 */
- (void)insertObject:(id)obj atIndex:(NSUInteger)index {
    [self.proxy insertObject:obj atIndex:index];
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
    [self notifyWithType:NSKeyValueChangeInsertion indexSet:set newValue:obj oldValue:nil];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self.proxy removeObjectAtIndex:index];
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
    [self notifyWithType:NSKeyValueChangeRemoval indexSet:set newValue:nil oldValue:nil];
}

//- (void)addObject:(id)obj { // will call insertObject:atIndex:
//    [self.proxy insertObject:obj atIndex:[self.proxy count]];
//}

//- (void)removeLastObject {
//    [self.proxy removeLastObject];
//}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)obj {
    [self.proxy replaceObjectAtIndex:index withObject:obj];
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
    [self notifyWithType:NSKeyValueChangeReplacement indexSet:set newValue:obj oldValue:nil];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    [self.proxy setObject:obj atIndexedSubscript:idx];
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:idx];
    [self notifyWithType:NSKeyValueChangeInsertion indexSet:set newValue:obj oldValue:nil];
}

- (void)addObjectsFromArray:(NSArray*)array {
//    NSUInteger count = self.arr.count;
//    NSRange range = {count, array.count};
//    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
//    if (indexSet.count > 0) {
//        // don't send meaningless KVO event
//        [self insertObjects:array atIndexes:indexSet];
//    }
    [self.proxy addObjectsFromArray:array];
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.proxy.count - array.count, array.count)];
    [self notifyWithType:NSKeyValueChangeInsertion indexSet:set newValue:array oldValue:nil];
}

- (void)removeAllObjects {
//    NSRange range = {0, self.arr.count};
//    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
//    if (indexSet.count > 0) {
//        // don't send meaningless KVO event
//        [self removeObjectsAtIndexes:indexSet];
//    }
    
//    don't use the following codes. each object removed will send
//    one KVO notification, which is very inefficient
//
//    arr returned is NSKeyValueNotifyingMutableArray
//    NSMutableArray* arr = [self mutableArrayValueForKey:@"arr"];
//    [arr removeAllObjects];
    [self.proxy removeAllObjects];
}


- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
//    [self.observer insertArr:objects atIndexes:indexes];
    [self.proxy insertObjects:objects atIndexes:indexes];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
//   [self.observer removeArrAtIndexes:indexes];
    [self.proxy removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
//    [self.observer replaceArrAtIndexes:indexes withArr:objects];
    [self.proxy replaceObjectsAtIndexes:indexes withObjects:objects];
}
@end
