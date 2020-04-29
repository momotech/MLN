//
//  NSObject+MLNKVO.h
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MLNReflect)
+ (NSArray <NSString *> *)mln_propertyKeys;
- (NSDictionary *)mln_toDictionary;
@end

NS_ASSUME_NONNULL_END
