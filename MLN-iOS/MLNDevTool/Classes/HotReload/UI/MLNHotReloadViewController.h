//
//  MLNHotLuaViewController.h
//  MLNDebugger_Example
//
//  Created by MoMo on 2019/6/14.
//  Copyright © 2019 MoMo.xiaoning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MLN/MLNKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNHotReloadViewController : MLNKitViewController

- (instancetype)initWithNavigationBarTransparent:(BOOL)transparent;
- (instancetype)initWithRegisterClasses:(nullable NSArray<Class<MLNExportProtocol>> *)regClasses extraInfo:(nullable NSDictionary *)extraInfo;
- (instancetype)initWithRegisterClasses:(nullable NSArray<Class<MLNExportProtocol>> *)regClasses extraInfo:(nullable NSDictionary *)extraInfo navigationBarTransparent:(BOOL)transparent;

- (instancetype)initWithEntryFilePath:(NSString *)entryFilePath extraInfo:(nullable NSDictionary *)extraInfo regClasses:(nullable NSArray<Class<MLNExportProtocol>> *)regClasses navigationBarTransparent:(BOOL)transparent;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
