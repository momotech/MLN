//
//  MLNTopTipView.m
//  MLNDebugTool
//
//  Created by MoMo on 2019/9/11.
//

#import "MLNTopTip.h"
#import <MLNKit.h>

#define kTopTipLabelHeight 24
#define kStatusBarHeight [MLNSystem lua_stateBarHeight]
#define kBGColor [UIColor colorWithRed:255.f/255.0 green:165.f/255.0 blue:0.f alpha:0.85f]

@interface MLNTopTip ()

@property (nonatomic, strong) UIView *topTipView;
@property (nonatomic, strong) UILabel *topTipLabel;

@end

@implementation MLNTopTip

+ (void)show:(NSString *)msg duration:(NSTimeInterval)duration
{
    [[self defaultInstance] show:msg duration:duration];
}

+ (void)hidden:(NSString *)msg duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
{
    [[self defaultInstance] hidden:msg duration:duration delay:delay];
}

+ (void)tip:(NSString *)msg duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
{
    [[self defaultInstance] tip:msg duration:duration delay:delay];
}

static MLNTopTip *_defaultInstance = nil;
+ (instancetype)defaultInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultInstance = [[MLNTopTip alloc] init];
    });
    return _defaultInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}
static CGRect tipViewHiddenRect;
static CGRect tipViewShowRect;
- (void)setupUI {
    tipViewHiddenRect = CGRectMake(0, -(kStatusBarHeight + kTopTipLabelHeight), [UIScreen mainScreen].bounds.size.width, kStatusBarHeight + kTopTipLabelHeight);
    tipViewShowRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kStatusBarHeight + kTopTipLabelHeight);
    
    _topTipView = [[UIView alloc] initWithFrame:tipViewHiddenRect];
    [_topTipView setBackgroundColor:kBGColor];
    
    self.topTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, [UIScreen mainScreen].bounds.size.width, kTopTipLabelHeight)];
    self.topTipLabel.textAlignment = NSTextAlignmentCenter;
    [_topTipView addSubview:self.topTipLabel];
    [[self getWindow] insertSubview:_topTipView atIndex:10000];
}

- (void)show:(NSString *)msg duration:(NSTimeInterval)duration
{
    self.topTipLabel.text = msg;
    [self.topTipView.layer removeAllAnimations];
    if (!CGRectEqualToRect(tipViewShowRect, self.topTipView.frame)) {
        [UIView animateWithDuration:duration animations:^{
            self.topTipView.frame = tipViewShowRect;
        }];
    }
}

- (void)hidden:(NSString *)msg duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
{
    self.topTipLabel.text = msg;
    [self.topTipView.layer removeAllAnimations];
    if (!CGRectEqualToRect(tipViewHiddenRect, self.topTipView.frame)) {
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.topTipView.frame = tipViewHiddenRect;
        } completion:nil];
    }
}

- (void)tip:(NSString *)msg duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
{
    self.topTipLabel.text = msg;
    [self.topTipView.layer removeAllAnimations];
    if (!CGRectEqualToRect(tipViewShowRect, self.topTipView.frame)) {
        [UIView animateWithDuration:duration animations:^{
            self.topTipView.frame = tipViewShowRect;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.topTipView.frame = tipViewHiddenRect;
            } completion:nil];
        }];
    }
}

- (UIWindow *)getWindow
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[[UIApplication sharedApplication] delegate] window];
    }
    return window;
}

@end
