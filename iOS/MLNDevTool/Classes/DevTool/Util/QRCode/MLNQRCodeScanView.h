//
//  MLNQRCodeScanView.h
//  MLNDebugTool
//
//  Created by MoMo on 2019/9/10.
//

#import <UIKit/UIKit.h>
#import "MLNQRCodesScanViewProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface MLNQRCodeScanView : UIView <MLNQRCodesScanViewProtocol>

+ (instancetype)QRCodeScanViewWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
