//
//  NSArray+MLNUISafety.m
//
//
//  Created by MoMo on 2018/11/21.
//

#import "NSArray+MLNUISafety.h"
#import "NSDictionary+MLNUISafety.h"

@implementation NSArray (MLNUISafety)

- (id)mlnui_objectAtIndex:(NSUInteger)index
{
#if MLNUICrashProtect
    if (index >= self.count) {
        return nil;
    }
#endif
    return [self objectAtIndex:index];
}

@end

@implementation NSMutableArray (MLNUISafety)

+ (instancetype)mlnui_arrayWithArray:(NSArray *)array
{
#if MLNUICrashProtect
    if (!(array &&
          ([array isKindOfClass:[NSArray class]] ||
           [array isKindOfClass:[NSMutableArray class]]))) {
              return [self array];
          }
#endif
    return [self arrayWithArray:array];
}

- (void)mlnui_addObject:(id)anObject
{
#if MLNUICrashProtect
    if (!anObject) return;
#endif
    [self addObject:anObject];
}

- (void)mlnui_addObjectsFromArray:(NSArray *)array
{
#if MLNUICrashProtect
    if (!(array &&
          ([array isKindOfClass:[NSArray class]] ||
           [array isKindOfClass:[NSMutableArray class]]))) return;
#endif
    [self addObjectsFromArray:array];
}

- (void)mlnui_insertObject:(id)anObject atIndex:(NSUInteger)index
{
#if MLNUICrashProtect
    if (!(anObject && index <= self.count)) return;
#endif
    [self insertObject:anObject atIndex:index];
}

- (void)mlnui_removeObjectAtIndex:(NSUInteger)index
{
#if MLNUICrashProtect
    if (index >= self.count) return;
#endif
    [self removeObjectAtIndex:index];
}

- (void)mlnui_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
#if MLNUICrashProtect
    if (!(anObject && index < self.count)) return;
#endif
    [self replaceObjectAtIndex:index withObject:anObject];
}

- (void)mlnui_removeObject:(id)anObject
{
#if MLNUICrashProtect
    if (!anObject) return;
#endif
    [self removeObject:anObject];
}

- (void)mlnui_removeObjects:(NSArray *)array
{
#if MLNUICrashProtect
    if (!(array &&
          ([array isKindOfClass:[NSArray class]] ||
           [array isKindOfClass:[NSMutableArray class]]))) return;
#endif
    [self removeObjectsInArray:array];
}

- (void)mlnui_exchangeObjectAtIndex:(NSUInteger)startIndex withOther:(NSUInteger)otherIndex
{
#if MLNUICrashProtect
    if (startIndex >= self.count || otherIndex >= self.count) return;
#endif
    [self exchangeObjectAtIndex:startIndex withObjectAtIndex:otherIndex];
}

- (void)mlnui_insertObjects:(NSArray *)objects fromIndex:(NSUInteger)fromIndex
{
#if MLNUICrashProtect
    if (!(objects && ([objects isKindOfClass:[NSArray class]] ||
                    [objects isKindOfClass:[NSMutableArray class]]))) return;
    if (fromIndex > self.count) return;
#endif
    NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndexesInRange:NSMakeRange(fromIndex, objects.count)];
    [self insertObjects:objects atIndexes:indexSet];
}

- (void)mlnui_removeObjectsFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
#if MLNUICrashProtect
    if (fromIndex >= self.count || toIndex >= self.count || fromIndex > toIndex) return;
#endif
    NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndexesInRange:NSMakeRange(fromIndex, toIndex - fromIndex+1)];
    [self removeObjectsAtIndexes:indexSet];
}

- (void)mlnui_replaceObjects:(NSArray *)objects fromIndex:(NSUInteger)fromIndex
{
#if MLNUICrashProtect
    if (!(objects &&
          ([objects isKindOfClass:[NSArray class]] ||
           [objects isKindOfClass:[NSMutableArray class]]))) return;
    if (!(fromIndex < self.count && objects.count > 0 && objects.count <= self.count - fromIndex)) return ;
#endif
    NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndexesInRange:NSMakeRange(fromIndex, objects.count)];
    [self replaceObjectsAtIndexes:indexSet withObjects:objects];
}

@end
