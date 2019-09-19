//
//  MLNOfflineDevToolPresenter.h
//  MLNDevTool
//
//  Created by MoMo on 2019/9/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNOfflineDevToolPresenter;
@protocol MLNOfflineDevToolPresenterDelegate <NSObject>

@optional
/**
 解析到二维码信息
 
 @param devToolPresenter 热重载的Presenter
 @param result 解析到的内容
 */
- (void)devToolPresenter:(MLNOfflineDevToolPresenter *)devToolPresenter readDataFromQRCode:(NSString *)result;

/**
 二维码解析错误
 
 @param devToolPresenter 热重载的Presenter
 @param error 错误信息
 */
- (void)devToolPresenter:(MLNOfflineDevToolPresenter *)devToolPresenter QRCodeOnError:(NSError *)error;

@end

@interface MLNOfflineDevToolPresenter : NSObject

@property (nonatomic, weak) id<MLNOfflineDevToolPresenterDelegate> delegate;

- (void)openUI;
- (void)closeUI;

@end

NS_ASSUME_NONNULL_END
