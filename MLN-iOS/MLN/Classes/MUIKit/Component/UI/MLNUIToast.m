//
//  MLNUIToast.m
//  
//
//  Created by MoMo on 2018/7/11.
//

#import "MLNUIToast.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"

#define kFontDefaultSize 14
#define kToastDefaultWidth 280
#define kToastDefaultPadding 6.f
#define kMUIDefaultAnimationDuration 1.5
#define kToastDefaultBackColor [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.75f]

@interface MLNUIToast ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, assign) BOOL isShowing;

@end
@implementation MLNUIToast

+ (instancetype)toastWithMessage:(NSString *)message duration:(CGFloat)duration
{
    if (message != nil && ![message isKindOfClass:[NSString class]]) {
        message = @"";
    }
    return [[MLNUIToast alloc] initWithMLNUILuaCore:nil message:message duration:duration];
}

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore message:(NSString *)message duration:(CGFloat)duration
{
    self = [super initWithMLNUILuaCore:luaCore];
    if (self) {
        if (message != nil && ![message isKindOfClass:[NSString class]]) {
            MLNUIKitLuaAssert(NO, @"The message type should be String!");
            message = @"";
        }
        [self setupUIWithText:message];
        [self showWithDuration:duration];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationDidChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:[UIDevice currentDevice]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:[UIDevice currentDevice]];
}

- (void)showWithDuration:(CGFloat)duration
{
    [self showAnimationIfNeed];
    CGFloat realDuration = fabs(duration - 0.0) < CGFLOAT_MIN? kMUIDefaultAnimationDuration : duration;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(realDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideAnimationIfNeed];
    });
}

#pragma mark - Animation
- (void)showAnimationIfNeed
{
    if (!self.isShowing) {
        self.isShowing= YES;
        [self showAnimation];
    }
}

- (void)hideAnimationIfNeed
{
    if (self.isShowing) {
         self.isShowing= NO;
        [self hideAnimation];
    }
}

-(void)showAnimation
{
    self.isShowing= YES;
    [UIView beginAnimations:@"show" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.25f];
    self.containerView.alpha = 1.f;
    [UIView commitAnimations];
}

-(void)hideAnimation
{
    [UIView beginAnimations:@"hide" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(unloadUI)];
    [UIView setAnimationDuration:0.25f];
    self.containerView.alpha = 0.f;
    [UIView commitAnimations];
}

#pragma mark - Setup UI
- (void)setupUIWithText:(NSString *)text
{
    CGSize size = [self calcuSizeWithText:text];
    [self setupContainerViewWithSize:size];
    [self setupMsgLabelWithSize:size msg:text];
}

- (void)setupContainerViewWithSize:(CGSize)size
{
    CGFloat bothOfPadding = kToastDefaultPadding *2;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, size.width + bothOfPadding, size.height + bothOfPadding)];
    containerView.center = window.center;
    containerView.alpha = 0.f;
    [window addSubview:containerView];
    // background layer
    CAShapeLayer *backLayer = [CAShapeLayer layer];
    backLayer.frame = containerView.bounds;
    backLayer.path = [UIBezierPath bezierPathWithRoundedRect:containerView.bounds cornerRadius:5.f].CGPath;
    backLayer.fillColor = kToastDefaultBackColor.CGColor;
    [containerView.layer addSublayer:backLayer];
    self.containerView = containerView;
}

- (void)setupMsgLabelWithSize:(CGSize)size msg:(NSString *)msg
{
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(kToastDefaultPadding, kToastDefaultPadding, size.width, size.height)];
    msgLabel.backgroundColor = [UIColor clearColor];
    msgLabel.textColor = [UIColor whiteColor];
    msgLabel.textAlignment = NSTextAlignmentCenter;
    msgLabel.font = [UIFont boldSystemFontOfSize:kFontDefaultSize];
    msgLabel.text = msg;
    msgLabel.numberOfLines = 0;
    [self.containerView addSubview:msgLabel];
    self.msgLabel = msgLabel;
}

- (CGSize)calcuSizeWithText:(NSString *)text
{
    CGSize size = CGSizeZero;
    if (text && text.length > 0) {
        UIFont *font = [UIFont boldSystemFontOfSize:kFontDefaultSize];
        size = [text boundingRectWithSize:CGSizeMake(kToastDefaultWidth, MAXFLOAT)
                                  options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                               attributes:@{NSFontAttributeName:font}
                                  context:nil].size;
    }
    
    return size;
}

- (void)unloadUI
{
    [self.containerView removeFromSuperview];
}

#pragma mark - Notifaction
- (void)deviceOrientationDidChanged:(NSNotification *)notification
{
    [self hideAnimationIfNeed];
}

#pragma mark - Export For Lua
LUA_EXPORT_BEGIN(MLNUIToast)
LUA_EXPORT_END(MLNUIToast, Toast, NO, NULL, "initWithMLNUILuaCore:message:duration:")

@end
