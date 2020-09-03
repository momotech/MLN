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
#import "ArgoLuaCacheAdapter.h"
#import "MLNUILuaTable.h"
#import "NSObject+MLNUICore.h"

@interface ArgoObservableMap()
@property (nonatomic, strong) NSMutableDictionary *proxy;
//
@property (nonatomic, strong) NSMutableDictionary *argoListeners;
@property (nonatomic, strong) ArgoLuaCacheAdapter *cacheAdapter;

@end

@implementation ArgoObservableMap

#pragma mark - ArgoListenerProtocol
- (NSObject *)lua_get:(NSString *)key {
    if(!key) return nil;
    return [self.proxy objectForKey:key];
}

- (void)lua_putValue:(NSObject *)value forKey:(NSString *)key {
    if(!key) return;
    if (value) {
        [self.proxy setObject:value forKey:key];
    } else {
        [self.proxy removeObjectForKey:key];
    }
    //lua table cache
    [self.cacheAdapter putValue:value forKey:key];
    
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    [change setObject:@(NSKeyValueChangeSetting) forKey:NSKeyValueChangeKindKey];
    if (value) {
        [change setObject:value forKey:NSKeyValueChangeNewKey];
    }
    [self notifyArgoListenerKey:key Change:change];
}

- (void)addLuaTabe:(MLNUILuaTable *)table {
    [self.cacheAdapter addLuaTabe:table];
}

- (MLNUILuaTable *)getLuaTable:(id<NSCopying>)key {
    return [self.cacheAdapter getLuaTable:key];
}

- (ArgoWatchWrapper * _Nonnull (^)(NSString * _Nonnull))watch {
    @weakify(self);
    return ^ArgoWatchWrapper *(NSString *keyPath) {
        @strongify(self);
        ArgoWatchWrapper *watch = [ArgoWatchWrapper new];
        watch.keyPath = keyPath;
        watch.observerd = self;
        return watch;
    };
}

#pragma mark -

- (NSMutableDictionary *)argoListeners {
    if (!_argoListeners) {
        _argoListeners = [NSMutableDictionary dictionary];
    }
    return _argoListeners;
}

- (ArgoLuaCacheAdapter *)cacheAdapter {
    if (!_cacheAdapter) {
        _cacheAdapter = [[ArgoLuaCacheAdapter alloc] initWithObject:self];
    }
    return _cacheAdapter;
}

- (void)dealloc {
//    if (_argoListeners.count) {
//        for (ArgoListenerWrapper *wrap in self.argoListeners) {
//            [wrap cancel];
//        }
//    }
}

- (MLNUINativeType)mlnui_nativeType {
    return MLNUINativeTypeObervableMap;
}

- (BOOL)mlnui_isConvertible {
    return NO;
}

#pragma mark - listener

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    [self lua_putValue:anObject forKey:(NSString *)aKey];
}

- (void)removeObjectForKey:(id)aKey {
    [self lua_putValue:nil forKey:aKey];
}

- (void)removeAllObjects {
    for (NSString *key in self.proxy.allKeys) {
        [self lua_putValue:nil forKey:key];
    }
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

+ (instancetype)dictionary {
    return [[self alloc] init];
}

+ (instancetype)dictionaryWithCapacity:(NSUInteger)numItems {
    return [[self alloc] initWithCapacity:numItems];
}

+ (instancetype)dictionaryWithObjectsAndKeys:(id)firstObject, ... {
    va_list args;
    va_start(args, firstObject);
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:firstObject,args, nil];
    va_end(args);
    return [[self alloc] initWithMutableDictonary:dic];
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
    return [self lua_get:aKey];
}

- (NSEnumerator *)keyEnumerator {
    return self.proxy.keyEnumerator;
}
@end
