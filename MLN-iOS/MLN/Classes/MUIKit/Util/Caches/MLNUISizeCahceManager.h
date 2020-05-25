//
//  MLNSizeCahceManager.h
//
//
//  Created by MoMo on 2018/11/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNKitInstance;

@interface MLNSizeCahceManager<KeyType, ObjectType> : NSObject

@property (nonatomic, weak, readonly) MLNKitInstance *instance;
@property (nonatomic) NSUInteger countLimit;

- (instancetype)initWithInstance:(MLNKitInstance *)instance;

- (nullable ObjectType)objectForKey:(KeyType)key;
- (void)setObject:(ObjectType)obj forKey:(KeyType)key;
- (void)removeObjectForKey:(KeyType)key;
- (void)removeAllObjects;

@end

NS_ASSUME_NONNULL_END
