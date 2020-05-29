//
//  NSObject+MLNUIKVO.h
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MLNUIReflect)
+ (NSArray <NSString *> *)mlnui_propertyKeys;
- (NSDictionary *)mlnui_toDictionary;
- (id)mlnui_valueForKeyPath:(NSString *)keyPath;

- (id)mlnui_convertToLuaObject;
- (id)mlnui_convertToNativeObject;

- (NSMutableDictionary *)mlnui_bindInfos;

@end

NS_ASSUME_NONNULL_END
