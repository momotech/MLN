//
//  MLNKitInstanceBuidler.h
//  MLN
//
//  Created by tamer on 2019/11/22.
//

#import <Foundation/Foundation.h>
#import "MLNViewControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNKitInstance;
@class MLNLuaBundle;
@interface MLNKitInstanceFactory : NSObject

+ (instancetype)defaultFactory;

- (void)preloadWithCapacity:(NSUInteger)capacity;

- (MLNKitInstance *)createKitInstanceWithViewController:(UIViewController<MLNViewControllerProtocol> *)viewController;
- (MLNKitInstance *)createKitInstanceWithLuaBundle:(MLNLuaBundle *__nullable)luaBundle viewController:(UIViewController<MLNViewControllerProtocol> *)viewController;
- (MLNKitInstance *)createKitInstanceWithLuaBundle:(MLNLuaBundle *__nullable)luaBundle rootView:(UIView *__nullable)rootView viewController:(UIViewController<MLNViewControllerProtocol> *)viewController;

@end

NS_ASSUME_NONNULL_END
