//
//  MLNSafeAreaProxy.m
//  MLN
//
//  Created by MoMo on 2019/12/19.
//

#import "MLNSafeAreaProxy.h"
#import "MLNDevice.h"

#define kNavigationBarFrame @"frame"
#define kNavigationBarHidden @"hidden"
#define kNavigationBarAlpha @"alpha"

@interface MLNSafeAreaProxy ()
{
    CGFloat _safeAreaBottom;
}

@property (nonatomic, copy) void(^safeAreaTopDidChanged)(CGFloat bottom);

@end

@implementation MLNSafeAreaProxy

- (instancetype)initWithNavigationBar:(UINavigationBar *)navigationBar viewController:(UIViewController *)viewController;
{
    if (self = [super init]) {
        _navigationBar = navigationBar;
        _viewController = viewController;
        _safeAreaBottom = [MLNDevice isIPHX] ? 34.f : 0.f;
        [self __addObserverWithNavigationBar:navigationBar];
    }
    return self;
}

- (void)safeAreaTopDidChanged:(void(^)(CGFloat bottom))callback
{
    self.safeAreaTopDidChanged = callback;
}

- (CGFloat)safeAreaTop
{
    return MAX([self __statusBarMaxY], [self __navBarMaxY]);
}

- (CGFloat)safeAreaBottom
{
    return _safeAreaBottom;
}

- (CGFloat)safeAreaLeft
{
    return 0.f;
}

- (CGFloat)safeAreaRight
{
    return 0.f;
}

#pragma mark - Private Method
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_navigationBar removeObserver:self forKeyPath:kNavigationBarFrame context:nil];
    [_navigationBar removeObserver:self forKeyPath:kNavigationBarHidden context:nil];
    [_navigationBar removeObserver:self forKeyPath:kNavigationBarAlpha context:nil];
}

- (void)__addObserverWithNavigationBar:(UINavigationBar *)navigationBar
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [navigationBar addObserver:self forKeyPath:kNavigationBarFrame options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [navigationBar addObserver:self forKeyPath:kNavigationBarHidden options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [navigationBar addObserver:self forKeyPath:kNavigationBarAlpha options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

- (CGFloat)__statusBarMaxY
{
    if (([self.viewController prefersStatusBarHidden] || [[UIApplication sharedApplication] isStatusBarHidden]) && ![MLNDevice isIPHX]) {
        return 0.f;
    }
    CGRect frame = [UIApplication sharedApplication].statusBarFrame;
    return frame.size.height + frame.origin.y;
}

- (CGFloat)__navBarMaxY
{
    if (self.navigationBar.hidden || self.navigationBar.alpha == 0) {
        return 0.f;
    }
    return self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height;
}

#pragma mark - Status Bar
- (void)didChangeStatusBarFrame
{
    if (self.safeAreaTopDidChanged) {
        self.safeAreaTopDidChanged([self safeAreaTop]);
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (([keyPath isEqualToString:kNavigationBarFrame] ||
         [keyPath isEqualToString:kNavigationBarHidden] ||
         [keyPath isEqualToString:kNavigationBarAlpha] ) &&
        self.safeAreaTopDidChanged) {
        self.safeAreaTopDidChanged([self safeAreaTop]);
    }
}

@end
