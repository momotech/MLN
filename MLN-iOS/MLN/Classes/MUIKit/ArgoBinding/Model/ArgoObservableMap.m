//
//  ArgoObservableMap.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/25.
//

#import "ArgoObservableMap.h"
#import "NSObject+ArgoListener.h"
#import "MLNUIExtScope.h"
#import "ArgoListenerWrapper.h"
#import "ArgoLuaCacheAdapter.h"
#import "MLNUILuaTable.h"
#import "NSObject+MLNUICore.h"

@interface ArgoObservableMap()
@property (nonatomic, strong) NSMutableDictionary *proxy;
//
@property (nonatomic, strong) NSMutableDictionary *argoListeners;
@property (nonatomic, strong) NSMutableDictionary *argoChangedKeysMap;

@property (nonatomic, strong) ArgoLuaCacheAdapter *cacheAdapter;
//@property (nonatomic, copy, readonly) ArgoObservableMap *(^set)(NSString *key, NSObject *value);
//@property (nonatomic, copy, readonly) NSObject *(^get)(NSString *key);
@end

@implementation ArgoObservableMap

#pragma mark - ArgoListenerProtocol
- (NSObject *)lua_get:(NSString *)key {
    if(!key) return nil;
    return [self.proxy objectForKey:key];
}

- (void)lua_putValue:(NSObject *)value forKey:(NSString *)key {
    [self _putValue:value forKey:key context:ArgoWatchContext_Lua notify:YES];
}

- (void)lua_rawPutValue:(NSObject *)value forKey:(NSString *)key {
    [self _putValue:value forKey:key context:ArgoWatchContext_Lua notify:NO];
}

- (void)native_putValue:(NSObject *)value forKey:(NSString *)key {
    [self _putValue:value forKey:key context:ArgoWatchContext_Native notify:YES];
}

- (NSObject *)native_getValueForKey:(NSString *)key {
    if(!key) return nil;
    return [self.proxy objectForKey:key];
}

- (void)_putValue:(NSObject *)value forKey:(NSString *)key context:(ArgoWatchContext)context notify:(BOOL)notify{
    if(!key) return;
    NSObject *old = [self.proxy objectForKey:key];
    if (value) {
        [self.proxy setObject:value forKey:key];
    } else {
        [self.proxy removeObjectForKey:key];
    }
    
    if (notify) {
        //lua table cache
        [self.cacheAdapter putValue:value forKey:key];
        
        NSMutableDictionary *change = [NSMutableDictionary dictionary];
        [change setObject:@(NSKeyValueChangeSetting) forKey:NSKeyValueChangeKindKey];
        if (value) {
            [change setObject:value forKey:NSKeyValueChangeNewKey];
        }
        if (old) {
            [change setObject:old forKey:NSKeyValueChangeOldKey];
        }
        [change setObject:@(context) forKey:kArgoListenerContext];
        
        [self.argoChangedKeysMap setObject:change forKey:key];
        [self notifyArgoListenerKey:key Change:change];
    }
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
        return [ArgoWatchWrapper wrapperWithKeyPath:keyPath observedObject:self];
    };
}

- (ArgoObservableMap * _Nonnull (^)(NSString * _Nonnull, NSObject * _Nonnull))set {
    @weakify(self);
    return ^(NSString *k, NSObject *v) {
        @strongify(self);
        [self native_putValue:v forKey:k];
        return self;
    };
}

- (NSObject * _Nonnull (^)(NSString * _Nonnull))get {
    @weakify(self);
    return ^(NSString *k) {
        @strongify(self);
        return [self native_getValueForKey:k];
    };
}
#pragma mark -

- (NSMutableDictionary *)argoListeners {
    if (!_argoListeners) {
        _argoListeners = [NSMutableDictionary dictionary];
    }
    return _argoListeners;
}

- (NSMutableDictionary *)argoChangedKeysMap {
    if (!_argoChangedKeysMap) {
        _argoChangedKeysMap = [NSMutableDictionary dictionary];
    }
    return _argoChangedKeysMap;
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
    [self native_putValue:anObject forKey:(NSString *)aKey];
}

- (void)removeObjectForKey:(id)aKey {
    [self native_putValue:nil forKey:aKey];
}

- (void)removeAllObjects {
    for (NSString *key in self.proxy.allKeys) {
        [self native_putValue:nil forKey:key];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    [self native_putValue:value forKey:key];
}

- (id)valueForKey:(NSString *)key {
    return [self native_getValueForKey:key];
}

- (id)mutableCopy {
    return [[ArgoObservableMap alloc] initWithMutableDictonary:self.proxy.mutableCopy];
}

- (id)argo_mutableCopy {
    return [[ArgoObservableMap alloc] initWithMutableDictonary:self.proxy.mutableCopy];
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

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    return [self initWithMutableDictonary:[NSMutableDictionary dictionaryWithDictionary:otherDictionary]];
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

- (void)encodeWithCoder:(NSCoder *)coder {
    [self.proxy encodeWithCoder:coder];
}

- (Class)classForCoder {
    return [self class];
}

- (Class)classForKeyedArchiver {
    return [self class];
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
    return [self native_getValueForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {
    return self.proxy.keyEnumerator;
}
@end
