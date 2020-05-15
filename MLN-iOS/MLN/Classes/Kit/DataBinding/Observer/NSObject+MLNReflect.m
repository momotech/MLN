//
//  NSObject+MLNKVO.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/19.
//

#import "NSObject+MLNKVO.h"
#import "MLNExtScope.h"
#import "MLNCore.h"
#import "MLNDataBinding+MLNKit.h"
#import "NSArray+MLNKVO.h"
#import "NSDictionary+MLNKVO.h"
#import "MLNColor.h"
#import "MLNRect.h"
#import "MLNSize.h"
#import "MLNPoint.h"

@import ObjectiveC;

@implementation NSObject (MLNReflect)

+ (void)mln_enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block {
    Class cls = self;
    BOOL stop = NO;

    unsigned count = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    if (properties == NULL) return;
    
    @onExit {
        free(properties);
    };

    for (unsigned i = 0; i < count; i++) {
        block(properties[i], &stop);
        if (stop) break;
    }
}

+ (NSArray <NSString *> *)mln_propertyKeys {
    return [self mln_propertyKeysWithBlock:nil];
}

+ (NSArray <NSString *> *)mln_propertyKeysWithBlock:(void(^)(NSString *key))block {
    NSArray *cachedKeys = objc_getAssociatedObject(self, @selector(mln_propertyKeys));
    if (cachedKeys != nil) {
        if (block) {
            [cachedKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                block(obj);
            }];
        }
        return cachedKeys;
    }
    
    NSMutableArray *keys = [NSMutableArray array];
    [self mln_enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        NSString *key = @(property_getName(property));
        [keys addObject:key];
        if (block) {
            block(key);
        }
    }];

    objc_setAssociatedObject(self, @selector(mln_propertyKeys), keys, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    return keys;
}


- (NSDictionary *)mln_toDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [self.class mln_propertyKeysWithBlock:^(NSString *key) {
        
        id obj = [self valueForKey:key];
        id obj2 = [obj mln_convertToLuaObject];
        
        [dic setValue:obj2 forKey:key];
    }];
    return dic.copy;
}

- (id)mln_valueForKeyPath:(NSString *)keyPath {
    if (keyPath) {
        return [self valueForKeyPath:keyPath];
    }
    return self;
}

- (id)mln_convertToLuaObject {
    MLNNativeType type = self.mln_nativeType;

    switch (type) {
        case MLNNativeTypeArray:
        case MLNNativeTypeMArray:
            return [(NSArray *)self mln_convertToLuaTableAvailable];
        case MLNNativeTypeDictionary:
        case MLNNativeTypeMDictionary:
            return [(NSDictionary *)self mln_convertToLuaTableAvailable];
        case MLNNativeTypeColor:
            return [[MLNColor alloc] initWithColor:(UIColor *)self];
        case MLNNativeTypeValue: {
            NSValue *value = (NSValue *)self;
            if (MLNValueIsCGRect(value)) {
                return [MLNRect rectWithCGRect:value.CGRectValue];
            } else if (MLNValueIsCGSize(value)) {
                return [MLNSize sizeWithCGSize:value.CGSizeValue];
            } else if (MLNValueIsCGPoint(value)) {
                return [MLNPoint pointWithCGPoint:value.CGPointValue];
            }
        }
        case MLNNativeTypeObject:
            return self.mln_toDictionary;
        default:
            break;
    }
    return self;
}

- (id)mln_convertToNativeObject {
    if ([self isKindOfClass:[NSArray class]]) {
        return [(NSArray *)self mln_convertToMArray];
    } else if ([self isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)self mln_convertToMDic];
    } else if ([self isKindOfClass:[MLNRect class]]) {
        return [NSValue valueWithCGRect:[(MLNRect *)self CGRectValue]];
    } else if ([self isKindOfClass:[MLNSize class]]) {
        return [NSValue valueWithCGSize:[(MLNSize *)self CGSizeValue]];
    } else if ([self isKindOfClass:[MLNPoint class]]) {
        return [NSValue valueWithCGPoint:[(MLNPoint *)self CGPointValue]];
    }
    return self;
}
@end
