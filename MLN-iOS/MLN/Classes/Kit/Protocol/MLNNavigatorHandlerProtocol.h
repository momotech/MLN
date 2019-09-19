//
//  MLNNavigatorDelegate.h
//  Pods
//
//  Created by MoMo on 2018/8/21.
//

#ifndef MLNNavigatorDelegate_h
#define MLNNavigatorDelegate_h
#import <UIKit/UIKit.h>
#import "MLNAnimationConst.h"
#import "MLNViewControllerProtocol.h"

@protocol MLNNavigatorHandlerProtocol <NSObject>

- (void)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController gotoPage:(NSString *)action params:(NSDictionary *)params animType:(MLNAnimationAnimType)animType;
- (void)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController gotoAndCloseSelf:(NSString *)action params:(NSDictionary *)params animType:(MLNAnimationAnimType)animType;
- (void)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController gotoLuaCodePage:(NSDictionary*)param animType:(MLNAnimationAnimType)animType;
- (void)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController closeSelf:(MLNAnimationAnimType)animType;
- (BOOL)viewController:(UIViewController<MLNViewControllerProtocol> *)viewController closeToLuaPage:(NSString *)pageName animateType:(MLNAnimationAnimType)animType;

@end

#endif /* MLNNavigatorDelegate_h */
