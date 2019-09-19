//
//  NSDictionary+MLNSafety.m
//
//
//  Created by MoMo on 2018/11/21.
//

#import "NSDictionary+MLNSafety.h"
#import "NSArray+MLNSafety.h"

@implementation NSDictionary (MLNSafety)

- (id)mln_objectForKey:(id)aKey
{
#ifdef MLNCrashProtect
    if (!aKey) return nil;
#endif
    return [self objectForKey:aKey];
}

@end

@implementation NSMutableDictionary (MLNSafety)

+ (instancetype)mln_dictionaryWithDictionary:(NSDictionary *)dict
{
#ifdef MLNCrashProtect
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
#ifdef MLNCrashProtect
    if (!aKey) return;
#endif
    [self removeObjectForKey:aKey];
}

- (void)mln_removeObjectsForKeys:(NSArray *)keyArray
{
#ifdef MLNCrashProtect
    if (!(keyArray &&
          ([keyArray isKindOfClass:[NSArray class]] ||
           [keyArray isKindOfClass:[NSMutableArray class]]))) return;
#endif
    [self removeObjectsForKeys:keyArray];
}

- (void)mln_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
#ifdef MLNCrashProtect
    if (!(aKey && anObject)) return;
#endif
    [self setObject:anObject forKey:aKey];
}

- (void)mln_setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues
{
#ifdef MLNCrashProtect
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
#ifdef MLNCrashProtect
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
#ifdef MLNCrashProtect
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
#ifdef MLNCrashProtect
    if (!(key && obj)) return;
#endif
    [self setObject:obj forKeyedSubscript:key];
}

@end
