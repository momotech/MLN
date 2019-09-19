//
//  NSArray+MLNSafety.m
//
//
//  Created by MoMo on 2018/11/21.
//

#import "NSArray+MLNSafety.h"
#import "NSDictionary+MLNSafety.h"

@implementation NSArray (MLNSafety)

- (id)mln_objectAtIndex:(NSUInteger)index
{
#if MLNCrashProtect
    if (index >= self.count) {
        return nil;
    }
#endif
    return [self objectAtIndex:index];
}

@end

@implementation NSMutableArray (MLNSafety)

+ (instancetype)mln_arrayWithArray:(NSArray *)array
{
#if MLNCrashProtect
    if (!(array &&
          ([array isKindOfClass:[NSArray class]] ||
           [array isKindOfClass:[NSMutableArray class]]))) {
              return [self array];
          }
#endif
    return [self arrayWithArray:array];
}

- (void)mln_addObject:(id)anObject
{
#if MLNCrashProtect
    if (!anObject) return;
#endif
    [self addObject:anObject];
}

- (void)mln_addObjectsFromArray:(NSArray *)array
{
#if MLNCrashProtect
    if (!(array &&
          ([array isKindOfClass:[NSArray class]] ||
           [array isKindOfClass:[NSMutableArray class]]))) return;
#endif
    [self addObjectsFromArray:array];
}

- (void)mln_insertObject:(id)anObject atIndex:(NSUInteger)index
{
#if MLNCrashProtect
    if (!(anObject && index <= self.count)) return;
#endif
    [self insertObject:anObject atIndex:index];
}

- (void)mln_removeObjectAtIndex:(NSUInteger)index
{
#if MLNCrashProtect
    if (index >= self.count) return;
#endif
    [self removeObjectAtIndex:index];
}

- (void)mln_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
#if MLNCrashProtect
    if (!(anObject && index < self.count)) return;
#endif
    [self replaceObjectAtIndex:index withObject:anObject];
}

- (void)mln_removeObject:(id)anObject
{
#if MLNCrashProtect
    if (!anObject) return;
#endif
    [self removeObject:anObject];
}

- (void)mln_removeObjects:(NSArray *)array
{
#if MLNCrashProtect
    if (!(array &&
          ([array isKindOfClass:[NSArray class]] ||
           [array isKindOfClass:[NSMutableArray class]]))) return;
#endif
    [self removeObjectsInArray:array];
}

- (void)mln_exchangeObjectAtIndex:(NSUInteger)startIndex withOther:(NSUInteger)otherIndex
{
#if MLNCrashProtect
    if (startIndex >= self.count || otherIndex >= self.count) return;
#endif
    [self exchangeObjectAtIndex:startIndex withObjectAtIndex:otherIndex];
}

- (void)mln_insertObjects:(NSArray *)objects fromIndex:(NSUInteger)fromIndex
{
#if MLNCrashProtect
    if (!(objects && ([objects isKindOfClass:[NSArray class]] ||
                    [objects isKindOfClass:[NSMutableArray class]]))) return;
    if (fromIndex > self.count) return;
#endif
    NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndexesInRange:NSMakeRange(fromIndex, objects.count)];
    [self insertObjects:objects atIndexes:indexSet];
}

- (void)mln_removeObjectsFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
#if MLNCrashProtect
    if (fromIndex >= self.count || toIndex >= self.count || fromIndex > toIndex) return;
#endif
    NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndexesInRange:NSMakeRange(fromIndex, toIndex - fromIndex+1)];
    [self removeObjectsAtIndexes:indexSet];
}

- (void)mln_replaceObjects:(NSArray *)objects fromIndex:(NSUInteger)fromIndex
{
#if MLNCrashProtect
    if (!(objects &&
          ([objects isKindOfClass:[NSArray class]] ||
           [objects isKindOfClass:[NSMutableArray class]]))) return;
    if (!(fromIndex < self.count && objects.count > 0 && objects.count <= self.count - fromIndex)) return ;
#endif
    NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndexesInRange:NSMakeRange(fromIndex, objects.count)];
    [self replaceObjectsAtIndexes:indexSet withObjects:objects];
}

@end
