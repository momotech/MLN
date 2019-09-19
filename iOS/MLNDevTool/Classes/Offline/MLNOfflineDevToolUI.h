//
//  MLNOfflineDevToolUI.h
//  MLNDevTool
//
//  Created by MoMo on 2019/9/11.
//

#import <Foundation/Foundation.h>
#import "MLNQRCodeHistoryViewControllerAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNOfflineDevToolUI;
@protocol MLNOfflineDevToolUIDelegate <NSObject>

- (void)devToolUI:(MLNOfflineDevToolUI *)devToolUI readDataFromQRCode:(NSString *)result;
- (void)devToolUI:(MLNOfflineDevToolUI *)devToolUI QRCodeOnError:(NSError *)error;
- (void)devToolUI:(MLNOfflineDevToolUI *)devToolUI changePort:(int)port;
- (int)currentPortDevToolUI:(MLNOfflineDevToolUI *)devToolUI;
- (void)devToolUI:(MLNOfflineDevToolUI *)devToolUI hiddenNavBar:(BOOL)hidden;

@end

@interface MLNOfflineDevToolUI : NSObject

@property (nonatomic, weak) id<MLNOfflineDevToolUIDelegate> delegate;
@property (nonatomic, weak) id<MLNQRCodeHistoryViewControllerAdapter> adapter;
@property (nonatomic, assign, readonly) BOOL isUtilViewControllerShow;

- (void)openUI;
- (void)closeUI;

- (void)closeQRCodeViewController:(BOOL)animated completion:(void (^ __nullable)(void))completion;
- (void)closeHistoryController:(BOOL)animated  completion:(void (^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
