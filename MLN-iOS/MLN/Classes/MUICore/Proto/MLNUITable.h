//
//  MLNUITable.h
//  ArgoUI
//
//  Created by xindong on 2020/11/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNUITable : NSObject

- (instancetype)initWithArray:(NSArray *)array;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (MLNUITable *)array;
+ (MLNUITable *)dictionary;

- (NSUInteger)count;
- (BOOL)contains:(id)object;

// get
- (nullable id)objectForKey:(id)key;
- (nullable id)firstObject;
- (nullable id)lastObject;

// update
- (void)setObject:(id)object forKey:(id)key;
- (void)addObject:(id)object;

// remove
- (void)removeObjectForKey:(id)key;
- (void)removeObject:(id)object;
- (void)removeAllObjects;

@end

NS_ASSUME_NONNULL_END
