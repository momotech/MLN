//
//  MLNHotReloadUI.h
//  MLNDebugTool
//
//  Created by MoMo on 2019/9/11.
//

#import <Foundation/Foundation.h>
#import "MLNQRCodeHistoryViewControllerAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNHotReloadUI;
@protocol MLNHotReloadUIDelegate <NSObject>

@optional
- (void)hotReloadUI:(MLNHotReloadUI *)hotReloadUI readDataFromQRCode:(NSString *)result;
- (void)hotReloadUI:(MLNHotReloadUI *)hotReloadUI QRCodeOnError:(NSError *)error;
- (void)hotReloadUI:(MLNHotReloadUI *)hotReloadUI changePort:(int)port;
- (int)currentPortHotReloadUI:(MLNHotReloadUI *)hotReloadUI;
- (void)hotReloadUI:(MLNHotReloadUI *)hotReloadUI hiddenNavBar:(BOOL)hidden;

- (void)hotReloadUI:(MLNHotReloadUI *)hotReloadUI setupDebugIP:(NSString *)ip port:(NSInteger)port;
- (NSString *)hotReloadUIGetDebugIP:(MLNHotReloadUI *)hotReloadUI;
- (NSString *)hotReloadUIGetDebugPort:(MLNHotReloadUI *)hotReloadUI;

@end

@interface MLNHotReloadUI : NSObject

@property (nonatomic, weak) id<MLNHotReloadUIDelegate> delegate;
@property (nonatomic, weak) id<MLNQRCodeHistoryViewControllerAdapter> adapter;
@property (nonatomic, assign, readonly) BOOL isUtilViewControllerShow;
@property (nonatomic, assign, readonly) BOOL isDebugMode;

- (void)openUI;
- (void)closeUI;

- (void)closeQRCodeViewController:(BOOL)animated completion:(void (^ __nullable)(void))completion;
- (void)closeHistoryController:(BOOL)animated  completion:(void (^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
