//
//  MLNHotReloadUI.m
//  MLNDebugTool
//
//  Created by MoMo on 2019/9/11.
//

#import "MLNHotReloadUI.h"
#import "MLNQRCodeViewController.h"
#import "MLNFloatingMenu.h"
#import "MLNHotReloadBundle.h"
#import "MLNQRCodeHistoryViewController.h"

#define kQRCoderIdx 0
#define kChangePortAlertIdx 1
#define kChangeNavBarAlertIdx 2

#define kInset 35.f
#define kMenuWidth 100.f

#if TARGET_IPHONE_SIMULATOR//模拟器
#define kAlertTitle @"模拟器连接端口"
#elif TARGET_OS_IPHONE//真机
#define kAlertTitle @"USB连接端口"
#endif

@interface MLNHotReloadUI () <MLNQRCodeViewControllerDelegate, MLNFloatingMenuDelegate>

@property (nonatomic, strong) MLNFloatingMenu *floatingMenu;
@property (nonatomic, strong) MLNQRCodeViewController *QRReader;
@property (nonatomic, strong) MLNQRCodeHistoryViewController *historyViewController;
@property (nonatomic, strong) UIAlertController *alert;

@end
@implementation MLNHotReloadUI

- (void)openUI
{
    self.floatingMenu.hidden = NO;
    [self.floatingMenu removeFromSuperview];
    [[self getWindow] insertSubview:self.floatingMenu atIndex:10000];
}

- (void)closeUI
{
    _floatingMenu.hidden = YES;
}

- (void)closeQRCodeViewController:(BOOL)animated completion:(void (^)(void))completion
{
    __weak typeof(self) wself = self;
    [self.QRReader dismissViewControllerAnimated:animated completion:^{
        __strong typeof(wself) sself = wself;
        sself->_floatingMenu.hidden = NO;
        sself->_isUtilViewControllerShow = NO;
        if (completion) {
            completion();
        }
    }];
}

- (void)closeHistoryController:(BOOL)animated completion:(void (^)(void))completion
{
    [self.historyViewController dismissViewControllerAnimated:animated completion:completion];
}

#pragma mark - MLNFloatingMenuDelegate
- (UIImage *)floatingMenu:(MLNFloatingMenu *)floatingMenu imageWithName:(NSString *)name
{
    NSString *path = [[MLNHotReloadBundle hotReloadBundle] pngPathWithName:name];
    return [UIImage imageNamed:path];
}

- (void)floatingMenu:(MLNFloatingMenu *)floatingMenu didSelectedAtIndex:(NSUInteger)index
{
    switch (index) {
        case kQRCoderIdx:
            [self openQRCoder];
            break;
        case kChangePortAlertIdx:
            [self openChangePortAlert];
            break;
        case kChangeNavBarAlertIdx:
            [self openChangeNavBarAlert];
            break;
        default:
            break;
    }
}

- (MLNFloatingMenu *)floatingMenu
{
    if (!_floatingMenu) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _floatingMenu = [[MLNFloatingMenu alloc] initWithFrame:CGRectMake(size.width - kMenuWidth -kInset, size.height - kMenuWidth - kInset, kMenuWidth, kMenuWidth)];
        _floatingMenu.iconNames = @[@"scanme", @"setting",@"right"];
        _floatingMenu.delegate = self;
    }
    return _floatingMenu;
}

#pragma mark - Change Port
- (void)openChangePortAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kAlertTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancleAction];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) sself = weakSelf;
        int port = [[alert.textFields firstObject].text intValue];
        if ([sself.delegate respondsToSelector:@selector(hotReloadUI:changePort:)]) {
            [sself.delegate hotReloadUI:sself changePort:port];
        }
    }];
    [alert addAction:okAction];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        __strong typeof(weakSelf) sself = weakSelf;
        if ([sself.delegate respondsToSelector:@selector(currentPortHotReloadUI:)]) {
            int port = [sself.delegate currentPortHotReloadUI:sself];
            textField.text = [NSString stringWithFormat:@"%d", port];
        }
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }];
    self.alert = alert;
    [[self getTopViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)openChangeNavBarAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置导航栏状态" message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *showAction = [UIAlertAction actionWithTitle:@"展示" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(hotReloadUI:hiddenNavBar:)]) {
            [strongSelf.delegate hotReloadUI:strongSelf hiddenNavBar:NO];
        }
    }];
    [alert addAction:showAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"隐藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(hotReloadUI:hiddenNavBar:)]) {
            [strongSelf.delegate hotReloadUI:strongSelf hiddenNavBar:YES];
        }
    }];
    [alert addAction:okAction];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancleAction];
    self.alert = alert;
    [[self getTopViewController] presentViewController:alert animated:YES completion:nil];
}

#pragma mark - MLNQRCodeViewControllerDelegate
- (void)QRCodeViewController:(MLNQRCodeViewController *)QRCodeViewController readData:(NSString * __nullable)result
{
    [QRCodeViewController dismissViewControllerAnimated:YES completion:^{
        self->_floatingMenu.hidden = NO;
        self->_isUtilViewControllerShow = NO;
        if ([self.delegate respondsToSelector:@selector(hotReloadUI:readDataFromQRCode:)]) {
            [self.delegate hotReloadUI:self readDataFromQRCode:result];
        }
    }];
}

- (void)QRCodeViewController:(MLNQRCodeViewController *)QRCodeViewController error:(NSError * __nullable)error
{
    [QRCodeViewController dismissViewControllerAnimated:YES completion:^{
        self->_floatingMenu.hidden = NO;
        self->_isUtilViewControllerShow = NO;
        if ([self.delegate respondsToSelector:@selector(hotReloadUI:QRCodeOnError:)]) {
            [self.delegate hotReloadUI:self QRCodeOnError:error];
        }
    }];
}

- (void)onCancelQRCodeViewController:(MLNQRCodeViewController *)QRCodeViewController
{
    [QRCodeViewController dismissViewControllerAnimated:YES completion:^{
        self->_floatingMenu.hidden = NO;
        self->_isUtilViewControllerShow = NO;
    }];
}

- (void)openHistoryQRCodeViewController:(MLNQRCodeViewController *)QRCodeViewController
{
    self.historyViewController = [MLNQRCodeHistoryViewController historyViewController];
    self.historyViewController.adapter = self.adapter;
    [[self getTopViewController] presentViewController:self.historyViewController animated:YES completion:NULL];
}

- (void)openQRCoder {
    _floatingMenu.hidden = YES;
    _isUtilViewControllerShow = YES;
    [[self getTopViewController] presentViewController:self.QRReader animated:YES completion:NULL];
}

- (MLNQRCodeViewController *)QRReader {
    if (!_QRReader) {
        _QRReader = [[MLNQRCodeViewController alloc] init];
        _QRReader.delegate = self;
    }
    return _QRReader;
}

#pragma mark - Getter
- (UIWindow *)getWindow
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[[UIApplication sharedApplication] delegate] window];
    }
    return window;
}

- (UIViewController *)getTopViewController
{
    UIViewController *top = [self getWindow].rootViewController;
    while (top.presentedViewController) {
        top = top.presentedViewController;
    }
    return top;
}

@end
