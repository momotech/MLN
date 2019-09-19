//
//  MLNOfflineDevToolPresenter.m
//  MLNDevTool
//
//  Created by MoMo on 2019/9/11.
//

#import "MLNOfflineDevToolPresenter.h"
#import "MLNOfflineDevToolUI.h"
#import "MLNTopTip.h"
#import "MLNQRCodeResultManager.h"

@interface MLNOfflineDevToolPresenter () <MLNQRCodeHistoryViewControllerAdapter, MLNOfflineDevToolUIDelegate>

@property (nonatomic, strong) MLNOfflineDevToolUI *devToolUI;
@property (nonatomic, strong) MLNQRCodeResultManager *resultManager;

@end
@implementation MLNOfflineDevToolPresenter

- (void)openUI
{
    [self.devToolUI openUI];
}

- (void)closeUI
{
    [_devToolUI closeUI];
}

- (void)handle:(NSString *)result
{
    [self.resultManager addResult:result];
    if ([self.delegate respondsToSelector:@selector(devToolPresenter:readDataFromQRCode:)]) {
        [self.delegate devToolPresenter:self readDataFromQRCode:result];
    }
}

#pragma mark - MLNOfflineDevToolUIDelegate
- (void)devToolUI:(nonnull MLNOfflineDevToolUI *)devToolUI QRCodeOnError:(nonnull NSError *)error {
    if ([self.delegate respondsToSelector:@selector(devToolPresenter:QRCodeOnError:)]) {
        [self.delegate devToolPresenter:self QRCodeOnError:error];
    }
}

- (void)devToolUI:(nonnull MLNOfflineDevToolUI *)devToolUI readDataFromQRCode:(nonnull NSString *)result {
    [self handle:result];
}

#pragma mark - MLNQRCodeHistoryViewControllerAdapter

- (void)clearInfos:(nonnull MLNQRCodeHistoryViewController *)viewController {
    [self.resultManager removeAll];
}

- (void)closeHistoryViewController:(nonnull MLNQRCodeHistoryViewController *)viewController {
    [self.devToolUI closeHistoryController:YES completion:nil];
}

- (void)historyViewController:(nonnull MLNQRCodeHistoryViewController *)viewController didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    id<MLNQRCodeHistoryInfoProtocol> info = [self.resultManager resultAtIndex:indexPath.row];
    [self.devToolUI closeHistoryController:NO completion:nil];
    [self.devToolUI closeQRCodeViewController:NO completion:nil];
    [self handle:info.link];
}

- (nonnull id<MLNQRCodeHistoryInfoProtocol>)historyViewController:(nonnull MLNQRCodeHistoryViewController *)viewController infoForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [self.resultManager resultAtIndex:indexPath.row];
}

- (NSInteger)numberOfInfos:(nonnull MLNQRCodeHistoryViewController *)viewController {
    return [self.resultManager resultsCount];
}

#pragma mark - Getter
- (MLNOfflineDevToolUI *)devToolUI
{
    if (!_devToolUI) {
        _devToolUI = [[MLNOfflineDevToolUI alloc] init];
        _devToolUI.delegate = self;
        _devToolUI.adapter = self;
    }
    return _devToolUI;
}

- (MLNQRCodeResultManager *)resultManager
{
    if (!_resultManager) {
        _resultManager = [[MLNQRCodeResultManager alloc] init];
    }
    return _resultManager;
}

@end
