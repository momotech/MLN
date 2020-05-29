//
//  MLNUIViewController.h
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/4/24.
//

#import <UIKit/UIKit.h>
#import "MLNUIViewControllerProtocol.h"
#import "MLNUIExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#ifdef MLNUI_INTERNAL
#define MLNUI_INTERNAL_CONTROLLER MDViewController
#else
#define MLNUI_INTERNAL_CONTROLLER UIViewController
#endif

@class MLNUIKitInstanceHandlersManager;
@class MLNUIDataBinding;
@interface MLNUIViewController : MLNUI_INTERNAL_CONTROLLER <MLNUIViewControllerProtocol> {
    @protected
    MLNUIKitInstance *_kitInstance;
    MLNUIDataBinding *_dataBinding;
}

/**
 入口文件名
*/
@property (nonatomic, copy, readonly) NSString *entryFileName;
/**
 其他处理句柄的管理器
 */
@property (nonatomic, strong, readonly) MLNUIKitInstanceHandlersManager *handlerManager;
/**
 MLNUIViewController的代理
 */
@property (nonatomic, weak) id<MLNUIViewControllerDelegate> delegate;

- (instancetype)initWithEntryFileName:(NSString *)entryFileName;
- (instancetype)initWithEntryFileName:(NSString *)entryFileName bundle:(nullable NSBundle *)bundle NS_DESIGNATED_INITIALIZER;

// 废弃的初始化方法
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@property (nonatomic, copy) NSDictionary *extraInfo;
@property (nonatomic, copy) NSArray <Class<MLNUIExportProtocol>> *regClasses;
@end

NS_ASSUME_NONNULL_END
