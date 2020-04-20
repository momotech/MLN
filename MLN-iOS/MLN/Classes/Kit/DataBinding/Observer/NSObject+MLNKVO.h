//
//  NSObject+MLNKVO.h
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MLNKVOBlock)(id oldValue, id newValue);

@interface NSObject (MLNKVO)

@property(nonatomic, copy, readonly) NSObject *(^mln_subscribe)(NSString *keyPath, MLNKVOBlock block);

@end

@interface NSObject (MLNReflect)
+ (NSArray <NSString *> *)mln_propertyKeys;
- (NSDictionary *)mln_toDictionary;
@end

NS_ASSUME_NONNULL_END
