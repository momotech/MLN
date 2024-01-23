//
//  MLNTerminal.m
//  MLN
//
//  Created by MoMo on 2018/9/5.
//

#import "MLNConsole.h"
#import <MLN/MLNKit.h>

// Close
#define kConsoleTitleHeightClose 35.f
// Normal
#define kConsoleTitleHeight 40.f
#define kConsoleTitleIconWidth 20.f
#define kConsoleTitleIconSpacing 6.f
// Full Screen
#define kConsoleTitleHeightFullScreen 45.f
#define kConsoleTitleIconWidthFullScreen 30.f
#define kConsoleTitleIconSpacingFullScreen 16.f

@interface MLNConsole ()

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) MLNEditTextView *textView;
@property (nonatomic, strong) UIButton *scaleBtn;
@property (nonatomic, strong) UIButton *cleanBtn;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) dispatch_source_t source;
@property (nonatomic, copy) void(^updateTextTask)(void);
@property (nonatomic, copy) NSString *logMsg;
@property (nonatomic, strong) NSMutableAttributedString *logMsg_a;
@property (nonatomic, strong) dispatch_queue_t renderQueue;
@property (nonatomic, assign) CGRect normalFrame;

@end
@implementation MLNConsole

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.renderQueue = dispatch_queue_create("com.debug.console", DISPATCH_QUEUE_SERIAL);
        _status = MLNConsoleStatusNormal;
    }
    return self;
}

- (void)dealloc
{
    [self cancelSourceIfNeed];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.layer.borderWidth = 2.f;
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [self addSubview:self.titleView];
    [self addSubview:self.textView];
    [self.titleView addSubview:self.closeBtn];
    [self.titleView addSubview:self.cleanBtn];
    [self.titleView addSubview:self.titleLabel];
    [self.titleView addSubview:self.scaleBtn];
    [self changeStatus:MLNConsoleStatusClose];
}

#pragma mark - Print Log
- (void)printToConsole:(NSString *)msg
{
    doInMainQueue([self updateMsg:msg color:[UIColor colorWithWhite:0.f alpha:0.75] header:@"Log >> " hColor:[UIColor blackColor]];)
}

- (void)printErrorToConsole:(NSString *)msg
{
    doInMainQueue([self changeStatus:MLNConsoleStatusNormal];
                  [self updateMsg:msg color:[UIColor colorWithRed:1.f green:0.f blue:0.f alpha:0.5] header:@"Error >> " hColor:[UIColor redColor]];)
}

- (void)clean
{
    doInMainQueue(self.logMsg = @"";
                  self.logMsg_a = nil;
                  [self updateTextView:[self.logMsg_a copy] cleanEnable:[self cleanEnable]];);
}

- (void)updateMsg:(NSString *)msg color:(UIColor *)color header:(NSString *)header hColor:(UIColor *)hColor
{
    dispatch_async(self.renderQueue, ^{
        NSMutableAttributedString *as = self.logMsg_a;
        NSMutableAttributedString *logHeader = [[NSMutableAttributedString alloc] initWithString:header];
        [logHeader addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(0, logHeader.length)];
        [logHeader addAttribute:NSForegroundColorAttributeName value:hColor range:NSMakeRange(0, logHeader.length)];
        [as appendAttributedString:logHeader];
        NSMutableAttributedString *logMsg = [[NSMutableAttributedString alloc] initWithString:msg];
        [logMsg addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, logMsg.length)];
        [logMsg addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, logMsg.length)];
        [as appendAttributedString:logMsg];
        doInMainQueue(self.logMsg = as.string;
                      self.logMsg_a = as;
                      if (self.status != MLNConsoleStatusClose) {
                          [self updateTextView:[self.logMsg_a copy] cleanEnable:[self cleanEnable]];
                      });
    });
}

- (void)updateTextView:(NSAttributedString *)text cleanEnable:(BOOL)cleanEnable
{
    __weak typeof(self) wself = self;
    self.updateTextTask = ^{
        __strong typeof(wself) sself = wself;
        sself.textView.attributedText = text;
        sself.cleanBtn.enabled = cleanEnable;
    };
    [self createSourceIfNeed];
    [self updateSource];
}

- (BOOL)cleanEnable
{
    return (self.logMsg_a.length > 0);
}

#pragma mark - Change Status
- (void)changeStatus:(MLNConsoleStatus)status
{
    [self changeNormalFrameIfNeed];
    _status = status;
    switch (status) {
        case MLNConsoleStatusNormal:
            [self relayoutUIForNormal];
            break;
        case MLNConsoleStatusFullScreen:
            [self relayoutUIForFullScreen];
            break;
        default:
            [self relayoutUIForClose];
            break;
    }
}

- (void)changeNormalFrameIfNeed
{
    if (self.status == MLNConsoleStatusNormal) {
        self.normalFrame = self.frame;
    }
}

#pragma mark - Close Status
- (void)relayoutUIForClose
{
    CGFloat x = self.superview.frame.size.width - kConsoleTitleHeightClose;
    CGFloat y = self.normalFrame.origin.y;
    CGRect closeFrame = CGRectMake(x, y, kConsoleTitleHeightClose, kConsoleTitleHeightClose);
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = closeFrame;
        self.titleView.frame = self.bounds;
        self.closeBtn.frame = self.titleView.bounds;
    } completion:^(BOOL finished) {
        self.closeBtn.selected = NO;
        self.scaleBtn.selected = NO;
        self.scaleBtn.hidden = YES;
        self.cleanBtn.hidden = YES;
        self.textView.hidden = YES;
        self.titleLabel.hidden = YES;
    }];
}

#pragma mark - Normal Status
- (void)relayoutUIForNormal
{
    self.closeBtn.selected = YES;
    self.scaleBtn.selected = NO;
    CGFloat top = (kConsoleTitleHeight - kConsoleTitleIconWidth) * 0.5;
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = self.normalFrame;
        self.titleView.frame = CGRectMake(0.f, 0.f, self.frame.size.width, kConsoleTitleHeight);
        self.textView.frame = CGRectMake(0.f, kConsoleTitleHeight, self.frame.size.width, self.frame.size.height - kConsoleTitleHeight);
        self.scaleBtn.frame = CGRectMake(kConsoleTitleIconSpacing, top, kConsoleTitleIconWidth, kConsoleTitleIconWidth);
        self.cleanBtn.frame = CGRectMake(kConsoleTitleIconSpacing *2 + kConsoleTitleIconWidth, top, kConsoleTitleIconWidth, kConsoleTitleIconWidth);
        self.titleLabel.center = self.titleView.center;
        self.closeBtn.frame = CGRectMake(self.frame.size.width - kConsoleTitleIconWidth - kConsoleTitleIconSpacing, top, kConsoleTitleIconWidth, kConsoleTitleIconWidth);
        [self.textView lua_changedLayout];
    } completion:^(BOOL finished) {
        self.scaleBtn.hidden = NO;
        self.cleanBtn.hidden = NO;
        self.textView.hidden = NO;
        self.titleLabel.hidden = NO;
        [self updateTextView:[self.logMsg_a copy] cleanEnable:[self cleanEnable]];
    }];
}

#pragma mark - Full Screen Status
- (void)relayoutUIForFullScreen
{
    self.closeBtn.selected = YES;
    self.scaleBtn.selected = YES;
    self.scaleBtn.hidden = NO;
    self.cleanBtn.hidden = NO;
    self.textView.hidden = NO;
    self.titleLabel.hidden = NO;
    CGFloat stateHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    CGRect superBounds = self.superview.bounds;
    CGFloat top = (kConsoleTitleHeightFullScreen - kConsoleTitleIconWidthFullScreen) * 0.5f + stateHeight;
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = superBounds;
        self.titleView.frame = CGRectMake(0.f, 0.f, self.frame.size.width, kConsoleTitleHeightFullScreen + stateHeight);
        self.textView.frame = CGRectMake(0.f, kConsoleTitleHeightFullScreen + stateHeight, self.frame.size.width, self.frame.size.height - kConsoleTitleHeightFullScreen);
        self.scaleBtn.frame = CGRectMake(kConsoleTitleIconSpacingFullScreen, top, kConsoleTitleIconWidthFullScreen, kConsoleTitleIconWidthFullScreen);
        self.cleanBtn.frame = CGRectMake(kConsoleTitleIconSpacingFullScreen *2.f + kConsoleTitleIconWidthFullScreen, top, kConsoleTitleIconWidthFullScreen, kConsoleTitleIconWidthFullScreen);
        self.titleLabel.center = CGPointMake(self.titleView.frame.size.width *0.5f, kConsoleTitleHeightFullScreen*0.5f +stateHeight);
        self.closeBtn.frame = CGRectMake(self.frame.size.width - kConsoleTitleIconWidthFullScreen - kConsoleTitleIconSpacingFullScreen, top, kConsoleTitleIconWidthFullScreen, kConsoleTitleIconWidthFullScreen);
        [self.textView lua_changedLayout];
    }];
}

#pragma mark - Dispatch Source
- (void)createSourceIfNeed
{
    if (!_source) {
        _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_event_handler(_source,^{
            if (self.updateTextTask) {
                doInMainQueue(self.updateTextTask();)
            }
        });
        dispatch_resume(_source);
    }
}

- (void)cancelSourceIfNeed
{
    if (self.source) {
        dispatch_source_cancel(self.source);
        self.source = nil;
    }
}

- (void)updateSource
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.source) {
            dispatch_source_merge_data(self.source, 1);
        }
    });
}

#pragma mark - Actions
- (void)scaleAction:(UIButton *)btn
{
    if (btn.selected) {
        [self changeStatus:MLNConsoleStatusNormal];
    } else {
        [self changeStatus:MLNConsoleStatusFullScreen];
    }
}

- (void)openOrCloseAction:(UIButton *)btn
{
    if (btn.selected) {
        [self changeStatus:MLNConsoleStatusClose];
    } else {
        [self changeStatus:MLNConsoleStatusNormal];
    }
}

- (void)panAction:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint pt = [gestureRecognizer translationInView:self.superview];
    CGFloat centX = self.center.x +pt.x;
    CGFloat minCenterX = self.frame.size.width * 0.5f;
    centX = MAX(minCenterX, centX);
    CGFloat maxCenterX = self.superview.frame.size.width - minCenterX;
    centX = MIN(maxCenterX, centX);
    CGFloat centY = self.center.y +pt.y;
    CGFloat minCenterY = self.frame.size.height * 0.5f + CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    centY = MAX(minCenterY, centY);
    CGFloat maxCenterY = self.superview.frame.size.height - self.frame.size.height * 0.5f;
    centY = MIN(maxCenterY, centY);
    self.center = CGPointMake(centX , centY);
    [self changeNormalFrameIfNeed];
    [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
}

- (NSString *)imgPathWithName:(NSString *)name
{
    return [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"png"];
}

#pragma mark - Getter
- (UIView *)titleView
{
    if (!_titleView) {
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = [UIColor grayColor];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [_titleView addGestureRecognizer:pan];
    }
    return _titleView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"Console";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UIButton *)scaleBtn
{
    if (!_scaleBtn) {
        _scaleBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        NSString *path = [self imgPathWithName:@"largen"];
        [_scaleBtn setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
        NSString *s_path = [self imgPathWithName:@"diminish"];
        [_scaleBtn setImage:[UIImage imageWithContentsOfFile:s_path] forState:UIControlStateSelected];
        [_scaleBtn addTarget:self action:@selector(scaleAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scaleBtn;
}

- (UIButton *)cleanBtn
{
    if (!_cleanBtn) {
        _cleanBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        NSString *path = [self imgPathWithName:@"clean"];
        [_cleanBtn setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
        [_cleanBtn addTarget:self action:@selector(clean) forControlEvents:UIControlEventTouchUpInside];
        _cleanBtn.enabled = NO;
    }
    return _cleanBtn;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        NSString *path = [self imgPathWithName:@"left"];
        [_closeBtn setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
        NSString *s_path = [self imgPathWithName:@"right"];
        [_closeBtn setImage:[UIImage imageWithContentsOfFile:s_path] forState:UIControlStateSelected];
        [_closeBtn addTarget:self action:@selector(openOrCloseAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (MLNEditTextView *)textView
{
    if (!_textView) {
        _textView = [[MLNEditTextView alloc] init];
        _textView.canEdit = NO;
        _textView.text = @"";
    }
    return _textView;
}

- (NSString *)logMsg
{
    if (!_logMsg) {
        _logMsg = @"";
    }
    return _logMsg;
}

- (NSMutableAttributedString *)logMsg_a
{
    if (!_logMsg_a) {
        _logMsg_a = [[NSMutableAttributedString alloc] initWithString:@""];
    }
    return _logMsg_a;
}

@end
