//
//  NSObject+MLNUIKVO.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/19.
//

#import "NSObject+MLNUIKVO.h"
#import "MLNUIExtScope.h"
#import "MLNUICore.h"
#import "MLNUIDataBinding+MLNUIKit.h"
#import "NSArray+MLNUIKVO.h"
#import "NSDictionary+MLNUIKVO.h"
#import "MLNUIColor.h"
#import "MLNUIRect.h"
#import "MLNUISize.h"
#import "MLNUIPoint.h"

@import ObjectiveC;

@implementation NSObject (MLNUIReflect)

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
    if (self == [NSNull null]) {
        return self;
    }
    
    MLNUINativeType type = self.mln_nativeType;

    switch (type) {
        case MLNUINativeTypeArray:
        case MLNUINativeTypeMArray:
            return [(NSArray *)self mln_convertToLuaTableAvailable];
        case MLNUINativeTypeDictionary:
        case MLNUINativeTypeMDictionary:
            return [(NSDictionary *)self mln_convertToLuaTableAvailable];
        case MLNUINativeTypeColor:
            return [[MLNUIColor alloc] initWithColor:(UIColor *)self];
        case MLNUINativeTypeValue: {
            NSValue *value = (NSValue *)self;
            if (MLNUIValueIsCGRect(value)) {
                return [MLNUIRect rectWithCGRect:value.CGRectValue];
            } else if (MLNUIValueIsCGSize(value)) {
                return [MLNUISize sizeWithCGSize:value.CGSizeValue];
            } else if (MLNUIValueIsCGPoint(value)) {
                return [MLNUIPoint pointWithCGPoint:value.CGPointValue];
            }
        }
        case MLNUINativeTypeObject:
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
    } else if ([self isKindOfClass:[MLNUIRect class]]) {
        return [NSValue valueWithCGRect:[(MLNUIRect *)self CGRectValue]];
    } else if ([self isKindOfClass:[MLNUISize class]]) {
        return [NSValue valueWithCGSize:[(MLNUISize *)self CGSizeValue]];
    } else if ([self isKindOfClass:[MLNUIPoint class]]) {
        return [NSValue valueWithCGPoint:[(MLNUIPoint *)self CGPointValue]];
    }
    return self;
}
@end
