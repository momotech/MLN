//
//  MLNQRCodeViewController.h
//  Pods
//
//  Created by MoMo on 2019/9/6.
//

#import <Foundation/Foundation.h>
#import "MLNQRCodesScanViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNQRCodeViewController;
@protocol MLNQRCodeViewControllerDelegate <NSObject>

@optional
- (void)QRCodeViewController:(MLNQRCodeViewController *)QRCodeViewController readData:(NSString * __nullable)result;
- (void)QRCodeViewController:(MLNQRCodeViewController *)QRCodeViewController error:(NSError * __nullable)error;
- (void)onCancelQRCodeViewController:(MLNQRCodeViewController *)QRCodeViewController;
- (void)openHistoryQRCodeViewController:(MLNQRCodeViewController *)QRCodeViewController;

@end

@interface MLNQRCodeViewController : UIViewController

@property (nonatomic, weak) id<MLNQRCodeViewControllerDelegate> delegate;
- (void)setupScanView:(UIView<MLNQRCodesScanViewProtocol> *)scanView;

@end

NS_ASSUME_NONNULL_END
