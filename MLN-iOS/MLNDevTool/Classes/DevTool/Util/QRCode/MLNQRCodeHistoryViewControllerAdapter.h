//
//  MLNQRCodeHistoryViewControllerAdapter.h
//  MLNDevTool
//
//  Created by MoMo on 2019/9/14.
//

#ifndef MLNQRCodeHistoryViewControllerAdapter_h
#define MLNQRCodeHistoryViewControllerAdapter_h

#import "MLNQRCodeHistoryInfoProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNQRCodeHistoryViewController;
@protocol MLNQRCodeHistoryViewControllerAdapter <NSObject>

- (NSInteger)numberOfInfos:(MLNQRCodeHistoryViewController *)viewController;
- (id<MLNQRCodeHistoryInfoProtocol>)historyViewController:(MLNQRCodeHistoryViewController *)viewController infoForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)historyViewController:(MLNQRCodeHistoryViewController *)viewController didSelectRowAtIndexPath:( NSIndexPath *)indexPath;
- (void)clearInfos:(MLNQRCodeHistoryViewController *)viewController;
- (void)closeHistoryViewController:(MLNQRCodeHistoryViewController *)viewController;

@end

NS_ASSUME_NONNULL_END

#endif /* MLNQRCodeHistoryViewControllerAdapter_h */
