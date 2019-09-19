//
//  MLNOfflineDevToolUI.m
//  MLNDevTool
//
//  Created by MoMo on 2019/9/11.
//

#import "MLNOfflineDevToolUI.h"
#import "MLNQRCodeViewController.h"
#import "MLNFloatingMenu.h"
#import "MLNOfflineBundle.h"
#import "MLNConsole.h"

#define kQRCoderIdx 0
#define kReloadIdx 1
#define kDebug 2

#define kInset 35.f
#define kMenuWidth 100.f
#define kConsoleWidth 250.f
#define kConsoleHeight 280.f

#if TARGET_IPHONE_SIMULATOR//模拟器
#define kAlertTitle @"模拟器连接端口"
#elif TARGET_OS_IPHONE//真机
#define kAlertTitle @"USB连接端口"
#endif

@interface MLNOfflineDevToolUI () <MLNFloatingMenuDelegate, MLNQRCodeViewControllerDelegate>

@property (nonatomic, strong) MLNConsole *console;
@property (nonatomic, strong) MLNFloatingMenu *floatingMenu;
@property (nonatomic, strong) MLNQRCodeViewController *QRReader;
@property (nonatomic, strong) UIAlertController *alert;

@end
@implementation MLNOfflineDevToolUI

- (void)openUI
{
    self.floatingMenu.hidden = NO;
    [self.floatingMenu removeFromSuperview];
    UIWindow *window = [self getWindow];
    [window insertSubview:self.floatingMenu atIndex:10000];
    
    self.console.hidden = NO;
    [self.console removeFromSuperview];
    [window insertSubview:self.console atIndex:10000];
}

- (void)closeUI
{
    _floatingMenu.hidden = YES;
    _console.hidden = YES;
}

#pragma mark - MLNFloatingMenuDelegate
- (UIImage *)floatingMenu:(MLNFloatingMenu *)floatingMenu imageWithName:(NSString *)name
{
    NSString *path = [[MLNOfflineBundle offlineBundle] pngPathWithName:name];
    return [UIImage imageNamed:path];
}

- (void)floatingMenu:(MLNFloatingMenu *)floatingMenu didSelectedAtIndex:(NSUInteger)index
{
    switch (index) {
        case kQRCoderIdx:
            [self openQRCoder];
            break;
        case kReloadIdx:
            [self openChangePortAlert];
            break;
        case kDebug:
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

- (MLNConsole *)console
{
    if (!_console) {
        _console = [[MLNConsole alloc] initWithFrame:CGRectMake(20, 64, kConsoleWidth, kConsoleHeight)];
    }
    return _console;
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
//        if ([sself.delegate respondsToSelector:@selector(hotReloadUI:changePort:)]) {
//            [sself.delegate hotReloadUI:sself changePort:port];
//        }
    }];
    [alert addAction:okAction];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        __strong typeof(weakSelf) sself = weakSelf;
//        if ([sself.delegate respondsToSelector:@selector(currentPortHotReloadUI:)]) {
//            int port = [sself.delegate currentPortHotReloadUI:sself];
//            textField.text = [NSString stringWithFormat:@"%d", port];
//        }
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
//        if ([strongSelf.delegate respondsToSelector:@selector(hotReloadUI:hiddenNavBar:)]) {
//            [strongSelf.delegate hotReloadUI:strongSelf hiddenNavBar:NO];
//        }
    }];
    [alert addAction:showAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"隐藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
//        if ([strongSelf.delegate respondsToSelector:@selector(hotReloadUI:hiddenNavBar:)]) {
//            [strongSelf.delegate hotReloadUI:strongSelf hiddenNavBar:YES];
//        }
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
        if ([self.delegate respondsToSelector:@selector(devToolUI:readDataFromQRCode:)]) {
            [self.delegate devToolUI:self readDataFromQRCode:result];
        }
    }];
}

- (void)QRCodeViewController:(MLNQRCodeViewController *)QRCodeViewController error:(NSError * __nullable)error
{
    [QRCodeViewController dismissViewControllerAnimated:YES completion:^{
        self->_floatingMenu.hidden = NO;
        self->_isUtilViewControllerShow = NO;
        if ([self.delegate respondsToSelector:@selector(devToolUI:QRCodeOnError:)]) {
            [self.delegate devToolUI:self QRCodeOnError:error];
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
