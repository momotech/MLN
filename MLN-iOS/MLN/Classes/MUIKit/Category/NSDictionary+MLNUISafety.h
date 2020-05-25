//
//  NSDictionary+MLNUISafety.h
//
//
//  Created by MoMo on 2018/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<__covariant KeyType, __covariant ObjectType> (MLNUISafety)

- (ObjectType)mlnui_objectForKey:(KeyType)aKey;

@end

@interface NSMutableDictionary<KeyType, ObjectType> (MLNUISafety)

+ (instancetype)mlnui_dictionaryWithDictionary:(NSDictionary<KeyType, ObjectType> *)dict;
- (void)mlnui_removeObjectForKey:(KeyType)aKey;
- (void)mlnui_removeObjectsForKeys:(NSArray<KeyType> *)keyArray;;
- (void)mlnui_setObject:(ObjectType)anObject forKey:(KeyType <NSCopying>)aKey;
- (void)mlnui_setValuesForKeysWithDictionary:(NSDictionary<NSString *, id> *)keyedValues;
- (void)mlnui_addEntriesFromDictionary:(NSDictionary<KeyType, ObjectType> *)otherDictionary;
- (void)mlnui_setDictionary:(NSDictionary *)otherDictionary;
- (void)mlnui_setObject:(nullable ObjectType)obj forKeyedSubscript:(KeyType <NSCopying>)key;

@end

NS_ASSUME_NONNULL_END
