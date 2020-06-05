//
//  MLNUILoading.m
//
//
//  Created by MoMo on 2018/12/10.
//

#import "MLNUILoading.h"
#import "MLNUIKitHeader.h"
#import "MLNUIStaticExporterMacro.h"
#import "MLNUIView.h"
#import "MLNUIKitInstance.h"

typedef NS_ENUM(NSInteger, LoadingState) {
    LoadingStateIdle = 0,
    LoadingStateShow,
};

@interface MLNUILoading()
@property (nonatomic, assign) LoadingState state;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, copy) MLNUIOnDestroyCallback onDestroyCallback;

@end

static MLNUILoading *_loading = nil;

@implementation MLNUILoading

+ (void)luaui_show
{
    MLNUILoading *loading = [MLNUILoading createLoadingIfNeed];
    if (loading.state == LoadingStateShow) return;
    loading.state = LoadingStateShow;
    [loading setupViews];
    loading.backgroundView.hidden = NO;
    [loading layoutMaskAndIndicatorView];
    [loading addOnInstanceDestroyCallback:MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore])];
    [loading.indicatorView startAnimating];
}

+ (void)luaui_hide
{
    if (!_loading) return;
    if (_loading.state != LoadingStateIdle) {
        [_loading.indicatorView stopAnimating];
        [_loading.backgroundView removeFromSuperview];
        _loading.backgroundView.hidden = YES;
        [_loading removeOnInstanceDestroyCallback:MLNUI_KIT_INSTANCE([self mlnui_currentLuaCore])];
        _loading = nil;
    }
}

#pragma mark - private method
+ (MLNUILoading *)createLoadingIfNeed
{
    if (!_loading) {
        _loading = [[MLNUILoading alloc] init];
    }
    return _loading;
}

- (void)addOnInstanceDestroyCallback:(MLNUIKitInstance *)instance
{
    if (!self.onDestroyCallback) {
        self.onDestroyCallback = ^{
            [MLNUILoading luaui_hide];
        };
    }
    [instance addOnDestroyCallback:self.onDestroyCallback];
}

- (void)removeOnInstanceDestroyCallback:(MLNUIKitInstance *)instance
{
    if (self.onDestroyCallback) {
        [instance removeOnDestroyCallback:self.onDestroyCallback];
    }
}

- (void)setupViews
{
    [self.superWindow addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.contentView];
    [self.contentView addSubview:self.indicatorView];
}

- (void)layoutMaskAndIndicatorView
{
    self.backgroundView.frame = self.superWindow.frame;
    
    CGRect contentViewFrame = self.contentView.frame;
    CGFloat contentViewFrameX = (self.superWindow.frame.size.width - contentViewFrame.size.width) / 2;
    CGFloat contentViewFrameY = (self.superWindow.frame.size.height - contentViewFrame.size.height) / 2;
    self.contentView.frame = CGRectMake(contentViewFrameX, contentViewFrameY, contentViewFrame.size.width, contentViewFrame.size.height);
    
    CGRect indicatorFrame = self.indicatorView.frame;
    CGFloat indicatorViewX = (self.contentView.frame.size.width - indicatorFrame.size.width) / 2;
    CGFloat indicatorViewY = (self.contentView.frame.size.height - indicatorFrame.size.height) / 2;
    self.indicatorView.frame = CGRectMake(indicatorViewX, indicatorViewY, indicatorFrame.size.width, indicatorFrame.size.height);
}

- (UIView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    }
    
    return _backgroundView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(0, 0, 60, 60);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        UIBlurEffect *effect =  [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        effectView.frame = _contentView.frame;
        [_contentView insertSubview:effectView atIndex:0];
#else
        _contentView.backgroundColor = [UIColor colorWithRed:116 green:120 blue:124 alpha:0.8];
#endif
        _contentView.layer.cornerRadius = 5.0f;
        _contentView.clipsToBounds = YES;
        [self.backgroundView addSubview:_contentView];
    }
    
    return _contentView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.frame = CGRectMake(0, 0, 45, 45);
    }
    return _indicatorView;
}

- (UIWindow *)superWindow
{
    return [UIApplication sharedApplication].keyWindow;
}

#pragma mark - Export For Lua
LUAUI_EXPORT_STATIC_BEGIN(MLNUILoading)
LUAUI_EXPORT_STATIC_METHOD(show, "luaui_show", MLNUILoading)
LUAUI_EXPORT_STATIC_METHOD(hide, "luaui_hide", MLNUILoading)
LUAUI_EXPORT_STATIC_END(MLNUILoading, Loading, NO, NULL)

@end
