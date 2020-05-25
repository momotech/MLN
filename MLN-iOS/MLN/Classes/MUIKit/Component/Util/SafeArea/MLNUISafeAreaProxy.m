//
//  MLNUISafeAreaProxy.m
//  MLNUI
//
//  Created by MoMo on 2019/12/19.
//

#import "MLNUISafeAreaProxy.h"
#import "MLNUIDevice.h"
#import "MLNUISafeAreaAdapter.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIKitEnvironment.h"

#define kStatusBarDefaultHeight 20.f
#define kStatusBarBusyHeight 40.f
#define kIphoneXStatusBarDefaultHeight 44.f
#define kIphoneXHomeIndicatorHeight 34.f
#define kViewrFrame @"frame"
#define kViewHidden @"hidden"
#define kViewAlpha @"alpha"

@interface MLNUISafeAreaProxy ()
{
    CGFloat _safeAreaBottom;
}
@property (nonatomic, assign) UIEdgeInsets lastSafeAreaInset;

@end

@implementation MLNUISafeAreaProxy

- (instancetype)initWithSafeAreaView:(UIView<MLNUISafeAreaViewProtocol> *)safeAreaView navigationBar:(UINavigationBar *)navigationBar viewController:(UIViewController *)viewController
{
    if (self = [super init]) {
        _safeAreaView = safeAreaView;
        _navigationBar = navigationBar;
        _viewController = viewController;
        _safeAreaBottom = [MLNUIDevice isIPHX] ? kIphoneXHomeIndicatorHeight : 0.f;
        [self __addObserverWithNavigationBar:navigationBar safeAreaView:safeAreaView];
        [self resestSafeAreaInsets];
    }
    return self;
}

- (void)setSafeArea:(MLNUISafeArea)safeArea
{
    if (_safeArea != safeArea) {
        _safeArea = safeArea;
        [self resestSafeAreaInsets];
    }
}

- (void)setAdapter:(MLNUISafeAreaAdapter *)adapter
{
    _adapter = adapter;
    __weak typeof(self) wself = self;
    [adapter updateInsets:^{
        __strong typeof(wself) sself = wself;
        [sself resestSafeAreaInsets];
    }];
    [self resestSafeAreaInsets];
}

- (CGFloat)safeAreaTop
{
    if (self.adapter) {
        return self.adapter.insetsTop;
    }
    return MAX([self __statusBarMaxY], [self __navBarMaxY]);
}

- (CGFloat)safeAreaBottom
{
    if (self.adapter) {
        return self.adapter.insetsBottom;
    }
    return _safeAreaBottom;
}

- (CGFloat)safeAreaLeft
{
    if (self.adapter) {
        return self.adapter.insetsLeft;
    }
    return 0.f;
}

- (CGFloat)safeAreaRight
{
    if (self.adapter) {
        return self.adapter.insetsRight;
    }
    return 0.f;
}

- (void)detachSafeAreaView:(UIView<MLNUISafeAreaViewProtocol> *)safeAreaView {
    [safeAreaView removeObserver:self forKeyPath:kViewrFrame context:nil];
    self.safeAreaView = nil;
}

#pragma mark - Private Method
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_navigationBar removeObserver:self forKeyPath:kViewrFrame context:nil];
    [_navigationBar removeObserver:self forKeyPath:kViewHidden context:nil];
    [_navigationBar removeObserver:self forKeyPath:kViewAlpha context:nil];
}

- (void)__addObserverWithNavigationBar:(UINavigationBar *)navigationBar safeAreaView:(UIView<MLNUISafeAreaViewProtocol> *)safeAreaView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resestSafeAreaInsets) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [safeAreaView addObserver:self forKeyPath:kViewrFrame options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [navigationBar addObserver:self forKeyPath:kViewrFrame options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [navigationBar addObserver:self forKeyPath:kViewHidden options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [navigationBar addObserver:self forKeyPath:kViewAlpha options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

- (CGFloat)__statusBarMaxY
{
    if (([self.viewController prefersStatusBarHidden] || [[UIApplication sharedApplication] isStatusBarHidden])) {
        if ([MLNUIDevice isIPHX]) {
            return kIphoneXStatusBarDefaultHeight;
        }
        return 0.f;
    }
    if ([self isIphoneBusy]) {
        return kStatusBarBusyHeight - kStatusBarDefaultHeight;
    }
    CGRect frame = [UIApplication sharedApplication].statusBarFrame;
    return CGRectGetMaxY(frame);
}

- (CGFloat)__navBarMaxY
{
    if (self.navigationBar.hidden || self.navigationBar.alpha == 0) {
        return 0.f;
    }
    return CGRectGetMaxY(self.navigationBar.frame);
}

- (BOOL)isIphoneBusy
{
    CGRect frame = [UIApplication sharedApplication].statusBarFrame;
    return kStatusBarBusyHeight == frame.size.height;
}

- (void)resestSafeAreaInsets
{
    UIEdgeInsets safeAreaInset = UIEdgeInsetsZero;
    UIWindow *window = [MLNUIKitEnvironment mainWindow];
    if (window) {
        CGRect frame = [self.safeAreaView convertRect:self.safeAreaView.frame toView:window];
        if (frame.origin.y <= 0 || ([self isIphoneBusy] && frame.origin.y <= kStatusBarBusyHeight - kStatusBarDefaultHeight)) {
            if (_safeArea & MLNUISafeAreaTop) {
                safeAreaInset.top = [self safeAreaTop];
            }
        }
        
        if (CGRectGetMaxY(frame) >= window.frame.size.height) {
            if (_safeArea & MLNUISafeAreaBottom) {
                safeAreaInset.bottom = [self safeAreaBottom];
            }
        }
        
        if (frame.origin.x <= 0) {
            if (_safeArea & MLNUISafeAreaLeft) {
                safeAreaInset.left = [self safeAreaLeft];
            }
        }
        
        if (CGRectGetMaxX(frame) >= window.frame.size.width) {
            if (_safeArea & MLNUISafeAreaRight) {
                safeAreaInset.right = [self safeAreaRight];
            }
        }
        [self.safeAreaView updateSafeAreaInsets:safeAreaInset];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ((object == self.safeAreaView && [keyPath isEqualToString:kViewrFrame]) ||
        (object == self.navigationBar && ([keyPath isEqualToString:kViewrFrame] ||
                                          [keyPath isEqualToString:kViewHidden] ||
                                          [keyPath isEqualToString:kViewAlpha]))) {
        [self resestSafeAreaInsets];
        [self.safeAreaView lua_requestLayout];
    }
}

@end
