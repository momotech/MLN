//
//  NSObject+ArgoListener.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#import "NSObject+ArgoListener.h"
#import "ArgoListenerWrapper.h"
#import "ArgoListenerToken.h"
#import "ArgoObservableArray.h"
#import "ArgoObservableMap.h"

NSString *const kArgoListenerArrayPlaceHolder = @"ARGO_PH";
NSString *const kArgoListenerArrayPlaceHolder_SUPER_IS_2D = @"ARGO_PH.ARGO_PH";
NSString *const kArgoListenerChangedObject = @"argo_changed_object";
NSString *const kArgoListenerChangedKey = @"argo_changeed_key";
NSString *const kArgoListenerWrapper = @"argo_wrapper";
//NSString *const kArgoListener2DArray = @"argo_2d_array";

@implementation NSObject (ArgoListener)
@dynamic argoListeners;
//
- (id<ArgoListenerProtocol>)argo_addListenerWithChangeBlock:(ArgoBlockChange)block object:(id<ArgoListenerProtocol>)object obID:(NSInteger)obid keyPath:(NSString *)keyPath paths:(NSArray *)paths prefix:(NSMutableString *)prefix {
    id<ArgoListenerProtocol>observed = object;
    for (int i = 0; i < paths.count; i++) {
        NSString *key = paths[i];
        ArgoListenerWrapper *wrapper = [ArgoListenerWrapper wrapperWithID:obid block:block observedObject:observed keyPath:keyPath key:key prefix:prefix.copy];
        if (prefix.length > 0) {
            [prefix appendString:@"."];
        }
        [prefix appendString:key];
        [object addArgoListenerWrapper:wrapper];
        object = (id<ArgoListenerProtocol>)[object get:key];
//        [wps addObject:wrapper];
    }
    return object;
}

- (void)argo_addArrayListenerWithChangeBlock:(ArgoBlockChange)block array:(ArgoObservableArray *)array obID:(NSInteger)obID observedObject:(id<ArgoListenerProtocol>)observedObject keyPath:(NSString *)keyPath {
    ArgoListenerWrapper *wrapper = [ArgoListenerWrapper wrapperWithID:obID block:block observedObject:observedObject keyPath:keyPath key:kArgoListenerArrayPlaceHolder prefix:keyPath];
    wrapper.arrayKeyPath = kArgoListenerArrayPlaceHolder;
    [array addArgoListenerWrapper:wrapper];
    //        [wps addObject:wrapper];
    //如果list是二维数组
    if (array.count > 0 && [array.firstObject isKindOfClass:[ArgoObservableArray class]]) {
        for (ArgoObservableArray *sub in array) {
            ArgoListenerWrapper *wrapper = [ArgoListenerWrapper wrapperWithID:obID block:block observedObject:observedObject keyPath:keyPath key:kArgoListenerArrayPlaceHolder prefix:keyPath];
            wrapper.arrayKeyPath = kArgoListenerArrayPlaceHolder_SUPER_IS_2D;
            [sub addArgoListenerWrapper:wrapper];
//                [wps addObject:wrapper];
        }
    }
}

static NSInteger ArgoOBID = 0;

- (id <ArgoListenerToken>)addArgoListenerWithChangeBlock:(ArgoBlockChange)block forKeyPath:(NSString *)keyPath {
//    NSMutableArray *wps = [NSMutableArray array];
    ArgoOBID++;
    NSArray *paths = [keyPath componentsSeparatedByString:@"."];
    id<ArgoListenerProtocol> object = (id<ArgoListenerProtocol>)self;
    // 依次添加监听：userData.data.list
    NSMutableString *prefix = [NSMutableString string];
    object = [self argo_addListenerWithChangeBlock:block object:object obID:ArgoOBID keyPath:keyPath paths:paths prefix:prefix];

    //如果list是数组
    ArgoObservableArray *array = (ArgoObservableArray *)object;
    if ([array isKindOfClass:[ArgoObservableArray class]]) {
        [self argo_addArrayListenerWithChangeBlock:block array:array obID:ArgoOBID observedObject:object keyPath:keyPath];
    }
    ArgoListenerToken *token = [ArgoListenerToken new];
//    token.wrappers = wps;
    token.block = block;
    token.keyPath = keyPath;
    token.tokenID = ArgoOBID;
    token.observedObject = (id<ArgoListenerProtocol>)self;
    return token;
}

- (void)removeArgoListenerWithToken:(ArgoListenerToken *)token {
    NSArray *paths = [token.keyPath componentsSeparatedByString:@"."];
    NSObject<ArgoListenerProtocol> *object = (NSObject<ArgoListenerProtocol> *)self;
    for (int i = 0; i < paths.count; i++) {
        [object removeListenerWithOBID:token.tokenID];
        NSString *key = paths[i];
        object = (NSObject<ArgoListenerProtocol> *)[object get:key];
    }
}

- (void)removeListenerWithOBID:(NSInteger)obid {
    for (ArgoListenerWrapper *wrap in self.argoListeners.copy) {
        if (wrap.obID == obid) {
            [self removeArgoListenerWrapper:wrap];
        }
    }
}

- (void)addArgoListenerWrapper:(ArgoListenerWrapper *)wrapper {
    if (wrapper && ![self.argoListeners containsObject:wrapper]) {
        [self.argoListeners addObject:wrapper];
    }
}

- (void)removeArgoListenerWrapper:(ArgoListenerWrapper *)wrapper {
    if (wrapper) {
        [self.argoListeners removeObject:wrapper];
    }
}

- (void)notifyArgoListenerKey:(NSString *)key Change:(NSMutableDictionary<NSKeyValueChangeKey,id> *)change {
    if(!key || !change) return;
    for (ArgoListenerWrapper *wrap in self.argoListeners.copy) {
        if (!wrap.block || ![wrap.key isEqualToString:key]) continue;
        
        if ([self isKindOfClass:[ArgoObservableMap class]]) {
            [self handleNotifyMapWithWrapper:wrap change:change];
        } else if([self isKindOfClass:[ArgoObservableArray class]]){
            [self handleNotifyArrayWithWrapper:wrap change:change];
        }
    }
}

- (void)handleNotifyMapWithWrapper:(ArgoListenerWrapper *)wrap change:(NSMutableDictionary<NSKeyValueChangeKey,id> *)change {
    if (wrap.keyPath.length > wrap.prefix.length && wrap.key) {
        NSUInteger len = wrap.prefix.length;
        NSString *subKeyPath = [wrap.keyPath substringFromIndex:MIN(wrap.keyPath.length, (len==0?0:len+1) + wrap.key.length + 1)];
        ArgoObservableMap *newMap = [change objectForKey:NSKeyValueChangeNewKey];
        id newV = newMap;
        if ([newMap isKindOfClass:[ArgoObservableMap class]]) {
            newV = [newMap argoGetForKeyPath:subKeyPath];
            [change setValue:newV forKey:NSKeyValueChangeNewKey];
            // 重新添加监听
            NSArray *subPaths = [subKeyPath componentsSeparatedByString:@"."];
            if (subPaths.count) {
                NSMutableString *prefix = wrap.prefix.mutableCopy;
                if (prefix.length > 0) {
                    [prefix appendString:@"."];
                }
                [prefix appendString:wrap.key];
                [self argo_addListenerWithChangeBlock:wrap.block object:newMap obID:wrap.obID keyPath:wrap.keyPath paths:subPaths prefix:prefix];
            }
        } else if([newMap isKindOfClass:[ArgoObservableArray class]]) {
            //如果是array，重新添加监听，需要处理二维
            [self argo_addArrayListenerWithChangeBlock:wrap.block array:(ArgoObservableArray *)newMap obID:wrap.obID observedObject:wrap.observedObject keyPath:wrap.keyPath];
        }
        [change setObject:self forKey:kArgoListenerChangedObject];
        [change setObject:wrap forKey:kArgoListenerWrapper];
        if (wrap.key) {
            [change setObject:wrap.key forKey:kArgoListenerChangedKey];
        }
        wrap.block(wrap.keyPath, wrap.observedObject, change);
    } else {
        NSLog(@"error, keypath.length <= prefix.length");
    }
}

- (void)handleNotifyArrayWithWrapper:(ArgoListenerWrapper *)wrap change:(NSMutableDictionary<NSKeyValueChangeKey,id> *)change {
//    NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
    ArgoObservableArray *newValue = [change objectForKey:NSKeyValueChangeNewKey];
//    NSIndexSet *set = [change objectForKey:NSKeyValueChangeIndexesKey];
    if ([newValue isKindOfClass:[ArgoObservableArray class]] && [wrap.arrayKeyPath isEqualToString:kArgoListenerArrayPlaceHolder]) { //self至少是二维，且arrayKeyPath=kArgoListenerArrayPlaceHolder,重新添加监听,防止监听kArgoListenerArrayPlaceHolder_SUPER_IS_2D
        ArgoListenerWrapper *arrayListener = [ArgoListenerWrapper wrapperWithID:wrap.obID block:wrap.block observedObject:wrap.observedObject keyPath:wrap.keyPath key:kArgoListenerArrayPlaceHolder prefix:wrap.prefix];
        [newValue addArgoListenerWrapper:arrayListener];
    }
    [change setObject:self forKey:kArgoListenerChangedObject];
    [change setObject:wrap forKey:kArgoListenerWrapper];
    if (wrap.key) {
        [change setObject:wrap.key forKey:kArgoListenerChangedKey];
    }
    wrap.block(wrap.keyPath, wrap.observedObject, change);
}

- (id)argoGetForKeyPath:(NSString *)keyPath {
    NSArray *paths = [keyPath componentsSeparatedByString:@"."];
    if (paths.count <= 0) {
        return nil;
    }
    id<ArgoListenerProtocol> object = (id<ArgoListenerProtocol>)self;
    for (NSString *kp in paths) {
        object = (id<ArgoListenerProtocol>)[object get:kp];
    }
    return object;
}

- (void)argoPutValue:(NSObject *)value forKeyPath:(NSString *)keyPath {
    NSArray *paths = [keyPath componentsSeparatedByString:@"."];
    if (paths.count <= 0) {
        return;
    }
    id<ArgoListenerProtocol> object = (id<ArgoListenerProtocol>)self;
    for (int i = 0; i < paths.count - 1; i++) {
        object = (id<ArgoListenerProtocol>)[object get:paths[i]];
    }
    [object putValue:value forKey: paths.lastObject];
}

@end


/*
 - (id <ArgoListenerToken>)addListenerWithChangeBlock:(ArgoBlockChange)block forKeyPath:(NSString *)keyPath {
 //    NSMutableArray *wps = [NSMutableArray array];

     NSArray *paths = [keyPath componentsSeparatedByString:@"."];
     id<ArgoListenerProtocol> object = (id<ArgoListenerProtocol>)self;
     // 依次添加监听：userData.data.list
     NSMutableString *prefix = [NSMutableString string];
     
     for (int i = 0; i < paths.count; i++) {
         NSString *key = paths[i];
         ArgoListenerWrapper *wrapper = [ArgoListenerWrapper wrapperWithID:ArgoOBID++ block:block keyPath:keyPath key:key prefix:prefix.copy];
         if (i != 0) {
             [prefix appendString:@"."];
         }
         [prefix appendString:key];
         [object addArgoListenerWrapper:wrapper];
         object = (id<ArgoListenerProtocol>)[object get:key];
 //        [wps addObject:wrapper];
     }
     //如果list是数组
     ArgoObservableArray *array = (ArgoObservableArray *)object;
     if ([array isKindOfClass:[ArgoObservableArray class]]) {
         ArgoListenerWrapper *wrapper = [ArgoListenerWrapper wrapperWithID:ArgoOBID++ block:block keyPath:keyPath key:kArgoListenerArrayPlaceHolder prefix:keyPath];
         [array addArgoListenerWrapper:wrapper];
 //        [wps addObject:wrapper];
         //如果list是二维数组
         if (array.count > 0 && [array.firstObject isKindOfClass:[ArgoObservableArray class]]) {
             for (ArgoObservableArray *sub in array) {
                 ArgoListenerWrapper *wrapper = [ArgoListenerWrapper wrapperWithID:ArgoOBID++ block:block keyPath:keyPath key:kArgoListenerArrayPlaceHolder prefix:keyPath];
                 [sub addArgoListenerWrapper:wrapper];
 //                [wps addObject:wrapper];
             }
         }
     }

     ArgoListenerToken *token = [ArgoListenerToken new];
 //    token.wrappers = wps;
     token.block = block;
     token.keyPath = keyPath;
     return token;
 }
 */
