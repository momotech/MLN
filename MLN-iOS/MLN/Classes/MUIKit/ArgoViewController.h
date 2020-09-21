//
//  ArgoViewController.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/28.
//

#import <UIKit/UIKit.h>
#import "ArgoViewControllerProtocol.h"
#import "MLNUIExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class ArgoDataBinding, ArgoKitInstanceHandlersManager;
@protocol ArgoViewModelProtocol;

@interface ArgoViewController : UIViewController <ArgoViewControllerProtocol>{
    @protected
    ArgoKitInstance *_kitInstance;
    ArgoDataBinding *_dataBinding;
}

/**
 入口文件名
*/
@property (nonatomic, copy, readonly) NSString *entryFileName;
/**
 其他处理句柄的管理器
 */
@property (nonatomic, strong, readonly) ArgoKitInstanceHandlersManager *handlerManager;
/**
 MLNUIViewController的代理
 */
@property (nonatomic, weak) id<ArgoViewControllerDelegate> delegate;

//- (instancetype)initWithEntryFileName:(NSString *)entryFileName;
- (instancetype)initWithEntryFileName:(NSString *)entryFileName bundleName:(nullable NSString *)bundleName;
//- (instancetype)initWithEntryFileName:(NSString *)entryFileName bundle:(nullable NSBundle *)bundle NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithModelClass:(Class<ArgoViewModelProtocol>)cls;

// 废弃的初始化方法
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@property (nonatomic, copy) NSDictionary *extraInfo;
@property (nonatomic, copy) NSArray <Class<ArgoExportProtocol>> *regClasses;

@end

NS_ASSUME_NONNULL_END
