//
//  NSArray+MLNSafety.h
//
//
//  Created by MoMo on 2018/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (MLNSafety)

- (ObjectType)mln_objectAtIndex:(NSUInteger)index;

@end

@interface NSMutableArray<ObjectType> (MLNSafety)

+ (instancetype)mln_arrayWithArray:(NSArray<ObjectType> *)array;
- (void)mln_addObject:(ObjectType)anObject;
- (void)mln_addObjectsFromArray:(NSArray *)array;
- (void)mln_insertObject:(ObjectType)anObject atIndex:(NSUInteger)index;
- (void)mln_removeObjectAtIndex:(NSUInteger)index;
- (void)mln_replaceObjectAtIndex:(NSUInteger)index withObject:(ObjectType)anObject;
- (void)mln_removeObject:(ObjectType)anObject;
- (void)mln_removeObjects:(NSArray<ObjectType> *)array;
- (void)mln_exchangeObjectAtIndex:(NSUInteger)startIndex withOther:(NSUInteger)otherIndex;
- (void)mln_insertObjects:(NSArray<ObjectType> *)objects fromIndex:(NSUInteger)fromIndex;
- (void)mln_removeObjectsFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)mln_replaceObjects:(NSArray<ObjectType> *)objects fromIndex:(NSUInteger)fromIndex;

@end

NS_ASSUME_NONNULL_END
