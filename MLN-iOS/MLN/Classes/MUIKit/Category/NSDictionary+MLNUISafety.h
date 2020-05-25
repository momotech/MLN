//
//  NSDictionary+MLNUISafety.h
//
//
//  Created by MoMo on 2018/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<__covariant KeyType, __covariant ObjectType> (MLNUISafety)

- (ObjectType)mln_objectForKey:(KeyType)aKey;

@end

@interface NSMutableDictionary<KeyType, ObjectType> (MLNUISafety)

+ (instancetype)mln_dictionaryWithDictionary:(NSDictionary<KeyType, ObjectType> *)dict;
- (void)mln_removeObjectForKey:(KeyType)aKey;
- (void)mln_removeObjectsForKeys:(NSArray<KeyType> *)keyArray;;
- (void)mln_setObject:(ObjectType)anObject forKey:(KeyType <NSCopying>)aKey;
- (void)mln_setValuesForKeysWithDictionary:(NSDictionary<NSString *, id> *)keyedValues;
- (void)mln_addEntriesFromDictionary:(NSDictionary<KeyType, ObjectType> *)otherDictionary;
- (void)mln_setDictionary:(NSDictionary *)otherDictionary;
- (void)mln_setObject:(nullable ObjectType)obj forKeyedSubscript:(KeyType <NSCopying>)key;

@end

NS_ASSUME_NONNULL_END
