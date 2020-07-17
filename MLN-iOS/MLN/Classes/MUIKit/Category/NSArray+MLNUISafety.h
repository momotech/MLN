//
//  NSArray+MLNUISafety.h
//
//
//  Created by MoMo on 2018/11/21.
//

#import <Foundation/Foundation.h>

#define MLNUICrashProtect 1

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (MLNUISafety)

- (ObjectType)mlnui_objectAtIndex:(NSUInteger)index;

@end

@interface NSMutableArray<ObjectType> (MLNUISafety)

+ (instancetype)mlnui_arrayWithArray:(NSArray<ObjectType> *)array;
- (void)mlnui_addObject:(ObjectType)anObject;
- (void)mlnui_addObjectsFromArray:(NSArray *)array;
- (void)mlnui_insertObject:(ObjectType)anObject atIndex:(NSUInteger)index;
- (void)mlnui_removeObjectAtIndex:(NSUInteger)index;
- (void)mlnui_replaceObjectAtIndex:(NSUInteger)index withObject:(ObjectType)anObject;
- (void)mlnui_removeObject:(ObjectType)anObject;
- (void)mlnui_removeObjects:(NSArray<ObjectType> *)array;
- (void)mlnui_exchangeObjectAtIndex:(NSUInteger)startIndex withOther:(NSUInteger)otherIndex;
- (void)mlnui_insertObjects:(NSArray<ObjectType> *)objects fromIndex:(NSUInteger)fromIndex;
- (void)mlnui_removeObjectsFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)mlnui_replaceObjects:(NSArray<ObjectType> *)objects fromIndex:(NSUInteger)fromIndex;

@end

NS_ASSUME_NONNULL_END
