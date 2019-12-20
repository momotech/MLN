//
//  MLNSafeAreaProxy.m
//  MLN
//
//  Created by MoMo on 2019/12/19.
//

#import "MLNSafeAreaProxy.h"
#import "MLNDevice.h"
#import "MLNSafeAreaAdapter.h"

#define kStatusBarDefaultHeight 20.f
#define kStatusBarBusyHeight 40.f
#define kIphoneXStatusBarDefaultHeight 44.f
#define kIphoneXHomeIndicatorHeight 34.f
#define kNavigationBarFrame @"frame"
#define kNavigationBarHidden @"hidden"
#define kNavigationBarAlpha @"alpha"

@interface MLNSafeAreaProxy ()
{
    CGFloat _safeAreaBottom;
}
@property (nonatomic, assign) UIEdgeInsets lastSafeAreaInset;

@end

@implementation MLNSafeAreaProxy

- (instancetype)initWithSafeAreaView:(UIView<MLNSafeAreaViewProtocol> *)safeAreaView navigationBar:(UINavigationBar *)navigationBar viewController:(UIViewController *)viewController
{
    if (self = [super init]) {
        _safeAreaView = safeAreaView;
        _navigationBar = navigationBar;
        _viewController = viewController;
        _safeAreaBottom = [MLNDevice isIPHX] ? kIphoneXHomeIndicatorHeight : 0.f;
        [self __addObserverWithNavigationBar:navigationBar safeAreaView:safeAreaView];
        [self resestSafeAreaInsets];
    }
    return self;
}

- (void)setSafeArea:(MLNSafeArea)safeArea
{
    if (_safeArea != safeArea) {
        _safeArea = safeArea;
        [self resestSafeAreaInsets];
    }
}

- (void)setAdapter:(MLNSafeAreaAdapter *)adapter
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

#pragma mark - Private Method
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_navigationBar removeObserver:self forKeyPath:kNavigationBarFrame context:nil];
    [_navigationBar removeObserver:self forKeyPath:kNavigationBarHidden context:nil];
    [_navigationBar removeObserver:self forKeyPath:kNavigationBarAlpha context:nil];
    [_safeAreaView removeObserver:self forKeyPath:kNavigationBarFrame context:nil];
}

- (void)__addObserverWithNavigationBar:(UINavigationBar *)navigationBar safeAreaView:(UIView<MLNSafeAreaViewProtocol> *)safeAreaView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resestSafeAreaInsets) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [safeAreaView addObserver:self forKeyPath:kNavigationBarFrame options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [navigationBar addObserver:self forKeyPath:kNavigationBarFrame options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [navigationBar addObserver:self forKeyPath:kNavigationBarHidden options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [navigationBar addObserver:self forKeyPath:kNavigationBarAlpha options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

- (CGFloat)__statusBarMaxY
{
    if (([self.viewController prefersStatusBarHidden] || [[UIApplication sharedApplication] isStatusBarHidden])) {
        if ([MLNDevice isIPHX]) {
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
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window) {
        CGRect frame = [self.safeAreaView convertRect:self.safeAreaView.frame toView:window];
        BOOL hasUpdated = NO;
        if (frame.origin.y <= 0 || ([self isIphoneBusy] && frame.origin.y <= kStatusBarBusyHeight - kStatusBarDefaultHeight)) {
            if (_safeArea & MLNSafeAreaTop) {
                safeAreaInset.top = [self safeAreaTop];
                hasUpdated = YES;
            }
        }
        
        if (CGRectGetMaxY(frame) >= window.frame.size.height) {
            if (_safeArea & MLNSafeAreaBottom) {
                safeAreaInset.bottom = [self safeAreaBottom];
                hasUpdated = YES;
            }
        }
        
        if (frame.origin.x <= 0) {
            if (_safeArea & MLNSafeAreaLeft) {
                safeAreaInset.left = [self safeAreaLeft];
                hasUpdated = YES;
            }
        }
        
        if (CGRectGetMaxX(frame) >= window.frame.size.width) {
            if (_safeArea & MLNSafeAreaRight) {
                safeAreaInset.bottom = [self safeAreaRight];
                hasUpdated = YES;
            }
        }
        if (hasUpdated) {
            [self.safeAreaView updateSafeAreaInsets:safeAreaInset];
        }
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ((object == self.safeAreaView && [keyPath isEqualToString:kNavigationBarFrame]) ||
        (object == self.navigationBar && ([keyPath isEqualToString:kNavigationBarFrame] ||
                                          [keyPath isEqualToString:kNavigationBarHidden] ||
                                          [keyPath isEqualToString:kNavigationBarAlpha]))) {
        [self resestSafeAreaInsets];
    }
}

@end
