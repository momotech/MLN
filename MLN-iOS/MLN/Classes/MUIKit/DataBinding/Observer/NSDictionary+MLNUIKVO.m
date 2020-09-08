//
//  NSDictionary+MLNUIKVO.m
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/3/12.
//

#import "NSDictionary+MLNUIKVO.h"
#import "NSObject+MLNUIReflect.h"
#import "MLNUIHeader.h"
#import "ArgoObservableMap.h"

@implementation NSDictionary (MLNUIKVO)

- (NSMutableDictionary *)mlnui_mutalbeCopy {
    NSMutableDictionary *copy = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (NSString *key in self.allKeys) {
        NSDictionary *value = [self objectForKey:key];
        if ([value respondsToSelector:@selector(mlnui_mutalbeCopy)]) {
            [copy setObject:value.mlnui_mutalbeCopy forKey:key];
        } else {
            [copy setObject:value forKey:key];
        }
    }
    return copy;
}

- (ArgoObservableMap *)argo_mutableCopy {
    ArgoObservableMap *copy = [ArgoObservableMap dictionaryWithCapacity:self.count];
    for (NSString *key in self.allKeys) {
        NSDictionary *value = [self objectForKey:key];
        if ([value respondsToSelector:@selector(argo_mutableCopy)]) {
            [copy setObject:value.argo_mutableCopy forKey:key];
        } else {
            [copy setObject:value forKey:key];
        }
    }
    return copy;
}

- (NSDictionary *)mlnui_convertToLuaTableAvailable {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSObject*  _Nonnull obj, BOOL * _Nonnull stop) {
        NSObject *n = [obj mlnui_convertToLuaObject];
        if (n) {
            [dic setObject:n forKey:key];
        }
    }];
    return dic.count > 0 ? dic.copy : self.copy;
}

- (NSMutableDictionary *)mlnui_convertToMDic {
#if OCPERF_USE_NEW_DB
    ArgoObservableMap *dic = [[ArgoObservableMap alloc] initWithCapacity:self.count];
#else
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:self.count];
#endif
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSObject *n = [obj mlnui_convertToNativeObject];
        if (n) {
            [dic setObject:n forKey:key];
        }
    }];
    return dic;
}
@end

@implementation NSMutableDictionary (MLNUIKVO)

- (NSMutableArray *)mlnui_allMutableKeys {
    NSMutableArray *keys = [NSMutableArray array];
    for (NSString *key in self.allKeys) {
        NSMutableDictionary *dic = [self objectForKey:key];
        if ([dic isKindOfClass:[NSMutableDictionary class]]) {
            [keys addObject:key];
        }
    }
    return keys;
}

- (NSDictionary *)mlnui_copy {
    NSMutableArray *keypaths = [self mlnui_allMutableKeys];
    [keypaths enumerateObjectsUsingBlock:^(NSString *  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *dic = [self valueForKey:key];
        NSAssert([dic isKindOfClass:[NSMutableDictionary class]], @"should be mutable");
        [self setValue:dic.mlnui_copy forKey:key];
    }];
    
    return self.copy;
}

- (void)mlnui_setValue:(id)value forKeyPath:(NSString *)keyPath createIntermediateObject:(BOOL)createIntermediateObject {
    if (createIntermediateObject) {
        NSArray *keys = [keyPath componentsSeparatedByString:@"."];
        NSMutableDictionary *dic = self;
        for (int i = 0; i < keys.count - 1; i++) {
            NSString *key = keys[i];
            NSMutableDictionary *tmp;
            if ([dic isKindOfClass:[NSMutableDictionary class]]) {
                tmp = [dic objectForKey:key];
            } else {
                tmp = [dic valueForKey:key];
            }
            if (!tmp) {
                tmp = [NSMutableDictionary dictionary];
                [dic setObject:tmp forKey:key];
            }
            dic = tmp;
        }
        [dic setValue:value forKey:keys.lastObject];
    } else {
        [self setValue:value forKeyPath:keyPath];
    }
}
@end
