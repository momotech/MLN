//
//  ArgoObservableMap.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/25.
//

#import "ArgoObservableMap.h"
#import "NSObject+ArgoListener.h"
#import "MLNExtScope.h"
#import "ArgoListenerWrapper.h"

@interface ArgoObservableMap()
@property (nonatomic, strong) NSMutableDictionary *proxy;
//
@property (nonatomic, strong) NSMutableDictionary *argoListeners;

@end

@implementation ArgoObservableMap

- (NSObject *)get:(NSString *)key {
    if(!key) return nil;
    return [self.proxy objectForKey:key];
}

- (void)putValue:(NSObject *)value forKey:(NSString *)key {
    if(!key) return;
    if (value) {
        [self.proxy setObject:value forKey:key];
    } else {
        [self.proxy removeObjectForKey:key];
    }

    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    [change setObject:@(NSKeyValueChangeSetting) forKey:NSKeyValueChangeKindKey];
    if (value) {
        [change setObject:value forKey:NSKeyValueChangeNewKey];
    }
    [self notifyArgoListenerKey:key Change:change];
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

#pragma mark - listener
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    [self putValue:anObject forKey:(NSString *)aKey];
}

- (void)removeObjectForKey:(id)aKey {
    [self putValue:nil forKey:aKey];
}

- (void)removeAllObjects {
    [self.proxy removeAllObjects];
}

#pragma mark -

- (instancetype)initWithMutableDictonary:(NSMutableDictionary *)dic {
    if (self = [super init]) {
        _proxy = dic;
    }
    return self;
}

- (instancetype)init {
    return [self initWithMutableDictonary:[NSMutableDictionary dictionary]];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:numItems];
    return [self initWithMutableDictonary:dic];
}

- (NSDictionary *)initWithContentsOfFile:(NSString *)path {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    return [self initWithMutableDictonary:dic];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    return [self initWithMutableDictonary:dic];
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
    return [self initWithMutableDictonary:dic];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [self.proxy encodeWithCoder:coder];
}

- (BOOL)isEqualToDictionary:(ArgoObservableMap *)otherDictionary {
    if (![otherDictionary isKindOfClass:[ArgoObservableMap class]]) {
        return NO;
    }
    return [self.proxy isEqualToDictionary:otherDictionary.proxy];
}

#pragma mark -

- (NSUInteger)count {
    return self.proxy.count;
}

- (id)objectForKey:(id)aKey {
    return [self get:aKey];
}

- (NSEnumerator *)keyEnumerator {
    return self.proxy.keyEnumerator;
}
@end
