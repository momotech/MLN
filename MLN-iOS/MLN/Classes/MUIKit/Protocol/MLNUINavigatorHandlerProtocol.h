//
//  MLNUINavigatorDelegate.h
//  Pods
//
//  Created by MoMo on 2018/8/21.
//

#ifndef MLNUINavigatorDelegate_h
#define MLNUINavigatorDelegate_h
#import <UIKit/UIKit.h>
#import "MLNUIAnimationConst.h"
#import "MLNUIViewControllerProtocol.h"

@protocol MLNUINavigatorHandlerProtocol <NSObject>

- (void)viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController gotoPage:(NSString *)action params:(NSDictionary *)params animType:(MLNUIAnimationAnimType)animType;
- (void)viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController gotoAndCloseSelf:(NSString *)action params:(NSDictionary *)params animType:(MLNUIAnimationAnimType)animType;
- (void)viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController gotoLuaCodePage:(NSDictionary*)param animType:(MLNUIAnimationAnimType)animType;
- (void)viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController closeSelf:(MLNUIAnimationAnimType)animType;
- (BOOL)viewController:(UIViewController<MLNUIViewControllerProtocol> *)viewController closeToLuaPage:(NSString *)pageName animateType:(MLNUIAnimationAnimType)animType;

@end

#endif /* MLNUINavigatorDelegate_h */
