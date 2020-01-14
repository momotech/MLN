//
//  MLNHotReloadPresenter.m
//  MLNDebugTool
//
//  Created by MoMo on 2019/9/11.
//

#import "MLNHotReloadPresenter.h"
#import "MLNHotReloadUI.h"
#import "MLNTopTip.h"
#import "MLNQRCodeResultManager.h"
#import "MLNDebugContext.h"

@interface MLNHotReloadPresenter () <MLNHotReloadUIDelegate, MLNQRCodeHistoryViewControllerAdapter>

@property (nonatomic, strong) MLNHotReloadUI *hotReloadUI;
@property (nonatomic, strong) MLNQRCodeResultManager *resultManager;

@end

@implementation MLNHotReloadPresenter

- (void)openUI
{
    [self.hotReloadUI openUI];
}

- (void)closeUI
{
    [_hotReloadUI closeUI];
}

- (void)show:(NSString *)msg duration:(NSTimeInterval)duration
{
    [MLNTopTip show:msg duration:duration];
}

- (void)hidden:(NSString *)msg duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
{
    [MLNTopTip hidden:msg duration:duration delay:delay];
}

- (void)tip:(NSString *)msg duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
{
    [MLNTopTip tip:msg duration:duration delay:delay];
}

- (BOOL)isUtilViewControllerShow
{
    return _hotReloadUI.isUtilViewControllerShow;
}

- (void)handle:(NSString *)result
{
    [self.resultManager addResult:result];
    NSArray *subStrs = [result componentsSeparatedByString:@":"];
    NSString *ip = subStrs[0];
    int port = [subStrs[1] intValue];
    
    if (self.hotReloadUI.isDebugMode) {
        [self setupDebugIP:ip port:8172];
        [MLNToast toastWithMessage:@"IP地址获取成功" duration:1.5f];
    } else {
        if ([self.delegate respondsToSelector:@selector(hotReloadPresenter:readDataFromQRCode:port:)]) {
            [self.delegate hotReloadPresenter:self readDataFromQRCode:ip port:port];
        }
    }
}

#pragma mark - MLNHotReloadUIDelegate
- (void)hotReloadUI:(MLNHotReloadUI *)hotReloadUI readDataFromQRCode:(NSString *)result
{
    if (!result || result.length <= 0) {
        return;
    }
    [self handle:result];
}

- (void)hotReloadUI:(MLNHotReloadUI *)hotReloadUI QRCodeOnError:(NSError *)error
{
    
}

- (void)hotReloadUI:(MLNHotReloadUI *)hotReloadUI changePort:(int)port
{
    if ([self.delegate respondsToSelector:@selector(hotReloadPresenter:changePort:)]) {
        return [self.delegate hotReloadPresenter:self changePort:port];
    }
}

- (int)currentPortHotReloadUI:(MLNHotReloadUI *)hotReloadUI
{
    if ([self.delegate respondsToSelector:@selector(currentPortHotReloadPresenter:)]) {
        return [self.delegate currentPortHotReloadPresenter:self];
    }
    return 0;
}

- (void)hotReloadUI:(MLNHotReloadUI *)hotReloadUI hiddenNavBar:(BOOL)hidden
{
    if ([self.delegate respondsToSelector:@selector(hotReloadPresenter:hiddenNavBar:)]) {
        return [self.delegate hotReloadPresenter:self hiddenNavBar:hidden];
    }
}

- (void)hotReloadUI:(MLNHotReloadUI *)hotReloadUI setupDebugIP:(NSString *)ip port:(NSInteger)port {
    if (ip.length == 0) {
        [MLNToast toastWithMessage:@"请输入正确的IP地址" duration:1.5f];
    } else if (port <= 0) {
        [MLNToast toastWithMessage:@"请输入正确的端口号" duration:1.5f];
    } else {
        [self setupDebugIP:ip port:port];
    }
}

- (void)setupDebugIP:(NSString *)ip port:(NSInteger)port {
    [MLNDebugContext sharedContext].ipAddress = ip;
    [MLNDebugContext sharedContext].port = port;
}

- (NSString *)hotReloadUIGetDebugIP:(MLNHotReloadUI *)hotReloadUI {
    return [MLNDebugContext sharedContext].ipAddress;
}

- (NSString *)hotReloadUIGetDebugPort:(MLNHotReloadUI *)hotReloadUI {
    if ([MLNDebugContext sharedContext].port > 0) {
        return [NSString stringWithFormat:@"%ld", (long)[MLNDebugContext sharedContext].port];
    }
    return @"8172";
}

#pragma mark - MLNQRCodeHistoryViewControllerAdapter

- (void)clearInfos:(nonnull MLNQRCodeHistoryViewController *)viewController {
    [self.resultManager removeAll];
}

- (void)closeHistoryViewController:(nonnull MLNQRCodeHistoryViewController *)viewController {
    [self.hotReloadUI closeHistoryController:YES completion:nil];
}

- (void)historyViewController:(nonnull MLNQRCodeHistoryViewController *)viewController didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    id<MLNQRCodeHistoryInfoProtocol> info = [self.resultManager resultAtIndex:indexPath.row];
    [self.hotReloadUI closeHistoryController:NO completion:nil];
    [self.hotReloadUI closeQRCodeViewController:NO completion:nil];
    [self handle:info.link];
}

- (nonnull id<MLNQRCodeHistoryInfoProtocol>)historyViewController:(nonnull MLNQRCodeHistoryViewController *)viewController infoForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [self.resultManager resultAtIndex:indexPath.row];
}

- (NSInteger)numberOfInfos:(nonnull MLNQRCodeHistoryViewController *)viewController {
    return [self.resultManager resultsCount];
}

#pragma mark - Getter
- (MLNHotReloadUI *)hotReloadUI
{
    if (!_hotReloadUI) {
        _hotReloadUI = [[MLNHotReloadUI alloc] init];
        _hotReloadUI.delegate = self;
        _hotReloadUI.adapter = self;
    }
    return _hotReloadUI;
}

- (MLNQRCodeResultManager *)resultManager
{
    if (!_resultManager) {
        _resultManager = [[MLNQRCodeResultManager alloc] init];
    }
    return _resultManager;
}

@end
