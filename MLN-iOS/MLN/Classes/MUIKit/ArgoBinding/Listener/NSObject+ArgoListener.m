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
NSString *const kArgoListenALL = @"ARGO_ALL";

NSString *const kArgoListenerChangedObject = @"argo_changed_object";
NSString *const kArgoListenerChangedKey = @"argo_changeed_key";
NSString *const kArgoListenerContext = @"argo_context";
NSString *const kArgoListenerWrapper = @"argo_wrapper";
//NSString const *const kArgoListener2DArray = @"argo_2d_array";
NSString *const kArgoListenerCallCountKey = @"argo_call_count";

NSString *const kArgoConstString_Dot = @".";

ArgoListenerFilter kArgoWatchKeyListenerFilter = ^BOOL(ArgoWatchContext context, NSDictionary *change) {
    ArgoListenerWrapper *wrap = [change objectForKey:kArgoListenerWrapper];
    if (!wrap.keyPath || !wrap.key) {
        return YES;
    }
    if ([wrap.keyPath isEqualToString:kArgoListenerArrayPlaceHolder]) { // TODO：数组的变化也会被watch到？
        return YES;
    }
    return [wrap.keyPath hasSuffix:wrap.key];
};

//只用于 ArgoObservableMap & ArgoObservableArray
@interface NSObject (ArgoListener) <ArgoListenerCategoryProtocol>
@end

@implementation NSObject (ArgoListener)
//@dynamic argoListeners;
//
- (id<ArgoListenerProtocol>)argo_addListenerWithChangeBlock:(ArgoBlockChange)block object:(id<ArgoListenerProtocol>)object obID:(NSInteger)obid keyPath:(NSString *)keyPath paths:(NSArray *)paths filter:(ArgoListenerFilter)filter triggerWhenAdd:(BOOL)triggerWhenAdd wrapper:(ArgoListenerWrapper *)wrapper {
    id<ArgoListenerProtocol>observed = object;
    BOOL useWrapper = !!wrapper;
    for (int i = 0; i < paths.count; i++) {
        NSString *key = paths[i];
        if (!useWrapper) {
            wrapper = [ArgoListenerWrapper wrapperWithID:obid block:block observedObject:observed keyPath:keyPath key:key filter:filter triggerWhenAdd:triggerWhenAdd];
        }
        [object addArgoListenerWrapper:wrapper];
        object = (id<ArgoListenerProtocol>)[object lua_get:key];
//        [wps addObject:wrapper];
    }
    return object;
}

- (void)argo_addArrayListenerWithChangeBlock:(ArgoBlockChange)block array:(ArgoObservableArray *)array obID:(NSInteger)obID observedObject:(id<ArgoListenerProtocol>)observedObject keyPath:(NSString *)keyPath filter:(ArgoListenerFilter)filter triggerWhenAdd:(BOOL)triggerWhenAdd wrapper:(ArgoListenerWrapper *)wrapper {
    BOOL useWrapper = !!wrapper;
    if (!useWrapper) {
        wrapper = [ArgoListenerWrapper wrapperWithID:obID block:block observedObject:observedObject keyPath:keyPath key:kArgoListenerArrayPlaceHolder filter:filter triggerWhenAdd:triggerWhenAdd];
        wrapper.arrayKeyPath = kArgoListenerArrayPlaceHolder;
    }
    [array addArgoListenerWrapper:wrapper];
    //        [wps addObject:wrapper];
    //如果list是二维数组
    if (array.count > 0 && [array.firstObject isKindOfClass:[ArgoObservableArray class]]) {
        for (ArgoObservableArray *sub in array) {
            if (!useWrapper) {
                wrapper = [ArgoListenerWrapper wrapperWithID:obID block:block observedObject:observedObject keyPath:keyPath key:kArgoListenerArrayPlaceHolder filter:filter triggerWhenAdd:triggerWhenAdd];
                wrapper.arrayKeyPath = kArgoListenerArrayPlaceHolder_SUPER_IS_2D;
            }
            [sub addArgoListenerWrapper:wrapper];
//                [wps addObject:wrapper];
        }
    }
}

+ (NSInteger)getID {
    static NSInteger ArgoOBID = 1;
    return ArgoOBID++;
}

//- (id <ArgoListenerToken>)addArgoListenerWithChangeBlock:(ArgoBlockChange)block forKeyPath:(NSString *)keyPath {
//    return [self addArgoListenerWithChangeBlock:block forKeyPath:keyPath filter:nil];
//}

- (id <ArgoListenerToken>)addArgoListenerWithChangeBlock:(ArgoBlockChange)block forKeyPath:(NSString *)keyPath filter:(ArgoListenerFilter)filter triggerWhenAdd:(BOOL)triggerWhenAdd {
    //    NSMutableArray *wps = [NSMutableArray array];
//        ArgoOBID++;
    if ([self isKindOfClass:[ArgoObservableArray class]]) {
        keyPath = nil;
    }
    NSInteger obid = [self.class getID];
    NSArray *paths = [keyPath componentsSeparatedByString:kArgoConstString_Dot];
    id<ArgoListenerProtocol> object = (id<ArgoListenerProtocol>)self;
    // 依次添加监听：userData.data.list
    object = [self argo_addListenerWithChangeBlock:block object:object obID:obid keyPath:keyPath paths:paths filter:filter triggerWhenAdd:triggerWhenAdd wrapper:nil];

    //如果list是数组
    ArgoObservableArray *array = (ArgoObservableArray *)object;
    if ([array isKindOfClass:[ArgoObservableArray class]]) {
        [self argo_addArrayListenerWithChangeBlock:block array:array obID:obid observedObject:object keyPath:keyPath filter:filter triggerWhenAdd:triggerWhenAdd wrapper:nil];
    }
    ArgoListenerToken *token = [ArgoListenerToken new];
//    token.wrappers = wps;
    token.block = block;
    token.keyPath = keyPath;
    token.tokenID = obid;
    token.observedObject = (id<ArgoListenerProtocol>)self;
    return token;
}

- (id<ArgoListenerToken>)addArgoListenerWithChangeBlockForAllKeys:(ArgoBlockChange)block filter:(ArgoListenerFilter)filter keyPaths:(NSArray *)keyPaths triggerWhenAdd:(BOOL)triggerWhenAdd {
    NSInteger obid = [self.class getID];
    ArgoListenerWrapper *wrapper = [ArgoListenerWrapper wrapperWithID:obid block:block observedObject:(id<ArgoListenerProtocol>)self keyPath:kArgoListenALL key:kArgoListenALL filter:filter triggerWhenAdd:triggerWhenAdd];
    for (NSString *kps in keyPaths) {
        id<ArgoListenerProtocol> object = (id<ArgoListenerProtocol>)self;
        NSArray *paths = [kps componentsSeparatedByString:kArgoConstString_Dot];
        object = [self argo_addListenerWithChangeBlock:nil object:object obID:0 keyPath:nil paths:paths filter:filter triggerWhenAdd:triggerWhenAdd wrapper:wrapper];

        ArgoObservableArray *array = (ArgoObservableArray *)object;
        if ([array isKindOfClass:[ArgoObservableArray class]]) {
            [self argo_addArrayListenerWithChangeBlock:nil array:array obID:0 observedObject:object keyPath:nil filter:filter triggerWhenAdd:triggerWhenAdd wrapper:wrapper];
        }
    }
    
    ArgoListenerToken *token = [ArgoListenerToken new];
//    token.wrappers = wps;
    token.block = block;
    token.keyPath = kArgoListenALL;
    token.tokenID = obid;
    token.observedObject = (id<ArgoListenerProtocol>)self;
    return token;
}

- (void)removeArgoListenerWithToken:(ArgoListenerToken *)token {
    NSArray *paths = [token.keyPath componentsSeparatedByString:kArgoConstString_Dot];
    NSObject<ArgoListenerProtocol> *object = (NSObject<ArgoListenerProtocol> *)self;
    [object removeListenerWithOBID:token.tokenID];
    
    for (int i = 0; i < paths.count; i++) {
        NSString *key = paths[i];
        object = (id<ArgoListenerProtocol>)[object lua_get:key];
        [object removeListenerWithOBID:token.tokenID];
    }
}

- (void)removeListenerWithOBID:(NSInteger)obid {
    [self.argoListeners removeObjectForKey:@(obid)];
}

- (void)addArgoListenerWrapper:(ArgoListenerWrapper *)wrapper {
    if (wrapper) {
        NSNumber *k = @(wrapper.obID);
        [self.argoListeners setObject:wrapper forKey:k];
        if ([self isKindOfClass:[ArgoObservableMap class]] && wrapper.triggerWhenAdd && wrapper.key && wrapper.filter) {
            NSMutableDictionary *dic = [self argoChangedKeysMap];
            NSMutableDictionary *change = [dic objectForKey:wrapper.key];
            if (change) {
                [change setObject:wrapper.key forKey:kArgoListenerChangedKey];
                [change setObject:wrapper forKey:kArgoListenerWrapper];
                //TODO: 是否传递新值?
//                [change setObject:[self argoGetForKeyPath:wrapper.key] forKey:NSKeyValueChangeNewKey];
                if([wrapper callWithChange:change]) {
                    [dic removeObjectForKey:wrapper.key];
                }
//                [self handleNotifyMapWithWrapper:wrapper change:change.mutableCopy];
            }
        }
    }
}

- (void)removeArgoListenerWrapper:(ArgoListenerWrapper *)wrapper {
    [self.argoListeners removeObjectForKey:@(wrapper.obID)];
}

- (void)notifyArgoListenerKey:(NSString *)key Change:(NSMutableDictionary<NSKeyValueChangeKey,id> *)change {
    if(!key || !change) return;
    for (ArgoListenerWrapper *wrap in self.argoListeners.allValues) {
        if (![wrap.key isEqualToString:kArgoListenALL]) {
            if (![wrap.key isEqualToString:key])
                continue;
        } else {
            //wrap.key == kArgoListenALL
        }
        
        if ([self isKindOfClass:[ArgoObservableMap class]]) {
            [self handleNotifyMapWithWrapper:wrap change:[change mutableCopy]];
        } else if([self isKindOfClass:[ArgoObservableArray class]]){
            [self handleNotifyArrayWithWrapper:wrap change:[change mutableCopy]];
        }
    }
}

- (void)handleNotifyMapWithWrapper:(ArgoListenerWrapper *)wrap change:(NSMutableDictionary<NSKeyValueChangeKey,id> *)change {
    if (wrap.key.length > 0) {
        BOOL reuseWrap = [wrap.key isEqualToString:kArgoListenALL];
        
        NSString *subKeyPath = @"";
        if (wrap.keyPath.length > wrap.key.length) {
            NSString *nk = [wrap.key stringByAppendingString:kArgoConstString_Dot];
            NSRange range = [wrap.keyPath rangeOfString:nk];
            if (range.location != NSNotFound) {
                subKeyPath = [wrap.keyPath substringFromIndex:MIN(wrap.keyPath.length, range.location + range.length)];
            }
        }
        ArgoObservableMap *newMap = [change objectForKey:NSKeyValueChangeNewKey];
        id newV = newMap;
        if ([newMap isKindOfClass:[ArgoObservableMap class]]) {
            if (subKeyPath.length > 0) {
                newV = [newMap argoGetForKeyPath:subKeyPath];
                [change setValue:newV forKey:NSKeyValueChangeNewKey];
            }
            // 重新添加监听
            NSArray *subPaths = [subKeyPath componentsSeparatedByString:kArgoConstString_Dot];
            if (subPaths.count) {
                id<ArgoListenerProtocol> obj = [self argo_addListenerWithChangeBlock:wrap.block object:newMap obID:wrap.obID keyPath:wrap.keyPath paths:subPaths filter:wrap.filter triggerWhenAdd:wrap.triggerWhenAdd wrapper:reuseWrap ? wrap : nil];
                ArgoObservableArray *array = (ArgoObservableArray *)obj;
                if ([array isKindOfClass:[ArgoObservableArray class]]) {
                    [self argo_addArrayListenerWithChangeBlock:wrap.block array:array obID:wrap.obID observedObject:wrap.observedObject keyPath:wrap.keyPath filter:wrap.filter triggerWhenAdd:wrap.triggerWhenAdd wrapper:reuseWrap ? wrap : nil];
                }
            }
        } else if([newMap isKindOfClass:[ArgoObservableArray class]]) {
            //如果是array，重新添加监听，需要处理二维
            [self argo_addArrayListenerWithChangeBlock:wrap.block array:(ArgoObservableArray *)newMap obID:wrap.obID observedObject:wrap.observedObject keyPath:wrap.keyPath filter:wrap.filter triggerWhenAdd:wrap.triggerWhenAdd wrapper:reuseWrap ? wrap : nil];
        }
        [change setObject:self forKey:kArgoListenerChangedObject];
        [change setObject:wrap forKey:kArgoListenerWrapper];
        if (wrap.key) {
            [change setObject:wrap.key forKey:kArgoListenerChangedKey];
        }
//        wrap.block(wrap.keyPath, wrap.observedObject, change);
        [wrap callWithChange:change];
    } else {
        NSLog(@"error, keypath.length <= prefix.length");
    }
}

- (void)handleNotifyArrayWithWrapper:(ArgoListenerWrapper *)wrap change:(NSMutableDictionary<NSKeyValueChangeKey,id> *)change {
//    NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
    ArgoObservableArray *newValue = [change objectForKey:NSKeyValueChangeNewKey];
//    NSIndexSet *set = [change objectForKey:NSKeyValueChangeIndexesKey];
    if ([newValue isKindOfClass:[ArgoObservableArray class]] && [wrap.arrayKeyPath isEqualToString:kArgoListenerArrayPlaceHolder]) { //self至少是二维，且arrayKeyPath=kArgoListenerArrayPlaceHolder,重新添加监听,防止监听kArgoListenerArrayPlaceHolder_SUPER_IS_2D
        ArgoListenerWrapper *arrayListener = [ArgoListenerWrapper wrapperWithID:wrap.obID block:wrap.block observedObject:wrap.observedObject keyPath:wrap.keyPath key:kArgoListenerArrayPlaceHolder filter:wrap.filter triggerWhenAdd:wrap.triggerWhenAdd];
        [newValue addArgoListenerWrapper:arrayListener];
    }
    [change setObject:self forKey:kArgoListenerChangedObject];
    [change setObject:wrap forKey:kArgoListenerWrapper];
    if (wrap.key) {
        [change setObject:wrap.key forKey:kArgoListenerChangedKey];
    }
//    wrap.block(wrap.keyPath, wrap.observedObject, change);
    [wrap callWithChange:change];
}

- (id)argoGetForKeyPath:(NSString *)keyPath {
    NSArray *paths = [keyPath componentsSeparatedByString:kArgoConstString_Dot];
    if (paths.count <= 0) {
        return nil;
    }
    id<ArgoListenerProtocol> object = (id<ArgoListenerProtocol>)self;
    for (NSString *kp in paths) {
        object = (id<ArgoListenerProtocol>)[object lua_get:kp];
    }
    return object;
}

- (void)argoPutValue:(NSObject *)value forKeyPath:(NSString *)keyPath {
    NSArray *paths = [keyPath componentsSeparatedByString:kArgoConstString_Dot];
    if (paths.count <= 0) {
        return;
    }
    id<ArgoListenerProtocol> object = (id<ArgoListenerProtocol>)self;
    for (int i = 0; i < paths.count - 1; i++) {
        object = (id<ArgoListenerProtocol>)[object lua_get:paths[i]];
    }
    [object lua_putValue:value forKey: paths.lastObject];
}

#pragma mark - 数据类型不匹配时防止crash
- (NSMutableDictionary<id<NSCopying>,ArgoListenerWrapper *> *)argoListeners { return nil; }
- (NSMutableDictionary *)argoChangedKeysMap { return nil;}
- (NSObject *)lua_get:(NSString *)key {return nil;}
- (void)lua_putValue:(NSObject *)value forKey:(NSString *)key {}
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
