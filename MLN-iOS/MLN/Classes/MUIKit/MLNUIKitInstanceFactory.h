//
//  MLNUIKitInstanceBuidler.h
//  MLNUI
//
//  Created by MoMo on 2019/11/22.
//

#import <Foundation/Foundation.h>
#import "MLNUIViewControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNUIKitInstance;
@class MLNUILuaBundle;
@interface MLNUIKitInstanceFactory : NSObject

+ (instancetype)defaultFactory;

- (void)preloadWithCapacity:(NSUInteger)capacity;

- (MLNUIKitInstance *)createKitInstanceWithViewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController;
- (MLNUIKitInstance *)createKitInstanceWithLuaBundle:(MLNUILuaBundle *__nullable)luaBundle viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController;
- (MLNUIKitInstance *)createKitInstanceWithLuaBundle:(MLNUILuaBundle *__nullable)luaBundle rootView:(UIView *__nullable)rootView viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController;

@end

NS_ASSUME_NONNULL_END
