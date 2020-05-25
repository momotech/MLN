//
//  NSObject+MLNUIKVO.h
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MLNUIReflect)
+ (NSArray <NSString *> *)mln_propertyKeys;
- (NSDictionary *)mln_toDictionary;
- (id)mln_valueForKeyPath:(NSString *)keyPath;

- (id)mln_convertToLuaObject;
- (id)mln_convertToNativeObject;
@end

NS_ASSUME_NONNULL_END
