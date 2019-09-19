//
//  MLNOfflineDevTool.m
//  MLNDevTool
//
//  Created by MoMo on 2019/9/11.
//

#import "MLNOfflineDevTool.h"
#import "MLNOfflineDevToolPresenter.h"

@interface MLNOfflineDevTool () {
    BOOL _running;
    BOOL _defaultIdleTimeStatus;
}

@property (nonatomic, weak) UIView *rootView;
@property (nonatomic, weak) UIViewController<MLNViewControllerProtocol> *viewController;
@property (nonatomic, strong) MLNOfflineDevToolPresenter *presenter;
@property (nonatomic, strong) MLNKitInstance *kitInstance;

@end

@implementation MLNOfflineDevTool

@synthesize isUtilViewControllerShow = _isUtilViewControllerShow;

static MLNOfflineDevTool *sharedInstance;
+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [MLNOfflineDevTool new];
    });
    return sharedInstance;
}

- (void)doLuaViewDidAppear {
    [self.kitInstance doLuaWindowDidAppear];
}


- (void)doLuaViewDidDisappear {
    [self.kitInstance doLuaWindowDidDisappear];
}

- (void)startWithRootView:(UIView *)rootView viewController:(UIViewController<MLNViewControllerProtocol> *)viewController
{
    if (_running) {
        return;
    }
    // 不息屏
    _defaultIdleTimeStatus = [UIApplication sharedApplication].idleTimerDisabled;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    _running = YES;
    self.rootView = rootView;
    self.viewController = viewController;
    [self.presenter openUI];
}


- (void)stop {
    [self.presenter closeUI];
}

- (void)error:(NSString *)error {
    
}

- (void)log:(NSString *)log {
    
}

@end
