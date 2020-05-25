//
//  NSDictionary+MLNUISafety.m
//
//
//  Created by MoMo on 2018/11/21.
//

#import "NSDictionary+MLNUISafety.h"
#import "NSArray+MLNUISafety.h"

@implementation NSDictionary (MLNUISafety)

- (id)mln_objectForKey:(id)aKey
{
#ifdef MLNUICrashProtect
    if (!aKey) return nil;
#endif
    return [self objectForKey:aKey];
}

@end

@implementation NSMutableDictionary (MLNUISafety)

+ (instancetype)mln_dictionaryWithDictionary:(NSDictionary *)dict
{
#ifdef MLNUICrashProtect
    if (!(dict &&
          ([dict isKindOfClass:[NSDictionary class]] ||
           [dict isKindOfClass:[NSMutableDictionary class]]))) {
              return [self dictionary];
          }
#endif
    return [self dictionaryWithDictionary:dict];
}

- (void)mln_removeObjectForKey:(id)aKey
{
#ifdef MLNUICrashProtect
    if (!aKey) return;
#endif
    [self removeObjectForKey:aKey];
}

- (void)mln_removeObjectsForKeys:(NSArray *)keyArray
{
#ifdef MLNUICrashProtect
    if (!(keyArray &&
          ([keyArray isKindOfClass:[NSArray class]] ||
           [keyArray isKindOfClass:[NSMutableArray class]]))) return;
#endif
    [self removeObjectsForKeys:keyArray];
}

- (void)mln_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
#ifdef MLNUICrashProtect
    if (!(aKey && anObject)) return;
#endif
    [self setObject:anObject forKey:aKey];
}

- (void)mln_setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues
{
#ifdef MLNUICrashProtect
    if (!(keyedValues &&
          ([keyedValues isKindOfClass:[NSDictionary class]] ||
           [keyedValues isKindOfClass:[NSMutableDictionary class]]))) {
              return;
          }
#endif
    [self setValuesForKeysWithDictionary:keyedValues];
}

- (void)mln_addEntriesFromDictionary:(NSDictionary *)otherDictionary
{
#ifdef MLNUICrashProtect
    if (!(otherDictionary &&
          ([otherDictionary isKindOfClass:[NSDictionary class]] ||
           [otherDictionary isKindOfClass:[NSMutableDictionary class]]))) {
              return;
          }
#endif
    [self addEntriesFromDictionary:otherDictionary];
}

- (void)mln_setDictionary:(NSDictionary *)otherDictionary
{
#ifdef MLNUICrashProtect
    if (!(otherDictionary &&
          ([otherDictionary isKindOfClass:[NSDictionary class]] ||
           [otherDictionary isKindOfClass:[NSMutableDictionary class]]))) {
              return;
          }
#endif
    [self setDictionary:otherDictionary];
}

- (void)mln_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
#ifdef MLNUICrashProtect
    if (!(key && obj)) return;
#endif
    [self setObject:obj forKeyedSubscript:key];
}

@end
