//
//  MLNHotLuaViewController.h
//  MLNDebugger_Example
//
//  Created by MoMo on 2019/6/14.
//  Copyright © 2019 feng.xiaoning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MLNKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNHotReloadViewController : UIViewController <MLNViewControllerProtocol>

- (instancetype)initWithNavigationBarTransparent:(BOOL)transparent;
- (instancetype)initWithRegisterClasses:(nullable NSArray<Class<MLNExportProtocol>> *)regClasses extraInfo:(nullable NSDictionary *)extraInfo;
- (instancetype)initWithRegisterClasses:(nullable NSArray<Class<MLNExportProtocol>> *)regClasses extraInfo:(nullable NSDictionary *)extraInfo navigationBarTransparent:(BOOL)transparent;

@end

NS_ASSUME_NONNULL_END
