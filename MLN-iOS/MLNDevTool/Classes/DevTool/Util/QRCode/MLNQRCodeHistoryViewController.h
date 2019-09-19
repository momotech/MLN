//
//  MLNQRCodeHistoryViewController.h
//  MLNDevTool
//
//  Created by MoMo on 2019/9/13.
//

#import <UIKit/UIKit.h>
#import "MLNQRCodeHistoryViewControllerAdapter.h"
NS_ASSUME_NONNULL_BEGIN

@interface MLNQRCodeHistoryViewController : UIViewController

+ (instancetype)historyViewController;

@property (nonatomic, weak) id<MLNQRCodeHistoryViewControllerAdapter> adapter;

@end

NS_ASSUME_NONNULL_END
