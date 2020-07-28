//
//  MLNUILogViewer.m
//  MLNDevTool
//
//  Created by Dongpeng Dai on 2020/7/9.
//

#import "MLNUILogViewer.h"
@interface MLNUILogViewer()
{
    BOOL isBeingDragged;
    BOOL isVisible;
}

@property (nonatomic) UITextView* tx_console;
@property (nonatomic) UIView* vw_container;
@end

@implementation MLNUILogViewer
+ (instancetype)sharedInstance
{
    static MLNUILogViewer* s_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ s_sharedInstance = self.new; });
    return s_sharedInstance;
}


+ (void)setup
{
    [MLNUILogViewer.sharedInstance tryToFindTopWindow];
}


+ (void)show
{
    [MLNUILogViewer.sharedInstance showWithAnimation];
}


+ (void)hide
{
    [MLNUILogViewer.sharedInstance hideWithAnimation];
}


+ (void)clear
{
    [MLNUILogViewer.sharedInstance clearConsole];
}

+ (void)addLog:(NSString *)log
{
    static BOOL isFirst = YES;
    if (isFirst) {
        isFirst = NO;
        [[MLNUILogViewer sharedInstance] clearConsole];
    }
    [[MLNUILogViewer sharedInstance] addLog:log];
}
#pragma mark -

- (void)tryToFindTopWindow
{
    if (!UIApplication.sharedApplication.keyWindow.subviews.lastObject)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tryToFindTopWindow) object:nil];
        [self performSelector:@selector(tryToFindTopWindow) withObject:nil afterDelay:0.1];
    }
    else
    {
        [self setup];
    }
}


- (void)setup
{
    // add three finger swipe down gesture for hiding
    UISwipeGestureRecognizer* swipeDownGestureRec = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(onSwipeDown:)];
    swipeDownGestureRec.direction = UISwipeGestureRecognizerDirectionDown;
    swipeDownGestureRec.numberOfTouchesRequired = 3;
    [UIApplication.sharedApplication.keyWindow addGestureRecognizer:swipeDownGestureRec];

    UISwipeGestureRecognizer* swipeLeftGestureRec = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(onSwipeDown:)];
    swipeLeftGestureRec.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeftGestureRec.numberOfTouchesRequired = 3;
    [UIApplication.sharedApplication.keyWindow addGestureRecognizer:swipeLeftGestureRec];
    
    // add three finger swipe up gesture for showing
    UISwipeGestureRecognizer* swipeUpGestureRec = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(onSwipeUp:)];
    swipeUpGestureRec.direction = UISwipeGestureRecognizerDirectionUp;
    swipeUpGestureRec.numberOfTouchesRequired = 3;
    [UIApplication.sharedApplication.keyWindow addGestureRecognizer:swipeUpGestureRec];

    UISwipeGestureRecognizer* swipeRightGestureRec = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(onSwipeUp:)];
    swipeRightGestureRec.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRightGestureRec.numberOfTouchesRequired = 3;
    [UIApplication.sharedApplication.keyWindow addGestureRecognizer:swipeRightGestureRec];
    
    // add container view with border, shadow, background color etc...
    CGFloat const consoleHeightRatio = 0.3;   // 0.0 to 1.0 from bottom to top
    CGFloat const margin = 40.0;               // margin in pixels
    CGRect initialRect = (CGRect)
    {
        margin,
        UIScreen.mainScreen.bounds.size.height * (1.0 - consoleHeightRatio),
        UIScreen.mainScreen.bounds.size.width - 2.0 * margin,
        UIScreen.mainScreen.bounds.size.height * consoleHeightRatio - margin
    };
    self.vw_container = [UIView.alloc initWithFrame:initialRect];
    self.vw_container.backgroundColor = [UIColor colorWithRed:156/255.0 green:82/255.0 blue:72/255.0 alpha:1];
    self.vw_container.alpha = 0.85;
    self.vw_container.layer.borderWidth = 1.0;
    self.vw_container.layer.borderColor = [UIColor colorWithRed:92/255.0 green:44/255.0 blue:36/255.0 alpha:1].CGColor;
    self.vw_container.layer.shadowColor = UIColor.blackColor.CGColor;
    self.vw_container.layer.shadowOffset = (CGSize){0.0, 2.0};
    self.vw_container.layer.shadowRadius = 3.0;
    self.vw_container.layer.shadowOpacity = 1.0;
    [UIApplication.sharedApplication.keyWindow addSubview:self.vw_container];

    // add long press gesture for moving
    UILongPressGestureRecognizer* longPressGestureRec = [UILongPressGestureRecognizer.alloc initWithTarget:self action:@selector(onLongPress:)];
    longPressGestureRec.minimumPressDuration = 0.2;
    [self.vw_container addGestureRecognizer:longPressGestureRec];

    UIPanGestureRecognizer *pan = [UIPanGestureRecognizer.alloc initWithTarget:self action:@selector(onPan:)];
    pan.maximumNumberOfTouches = 1;
    [self.vw_container addGestureRecognizer:pan];
    
    // add double tap press gesture for copying logs
    UITapGestureRecognizer* doubleTapGestureRec = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onDoubleTap:)];
    doubleTapGestureRec.numberOfTapsRequired = 2;
    [self.vw_container addGestureRecognizer:doubleTapGestureRec];

    // add triple tap press gesture for clearing logs
    UITapGestureRecognizer* tripleTapGestureRec = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onTripleTap:)];
    tripleTapGestureRec.numberOfTapsRequired = 3;
    [self.vw_container addGestureRecognizer:tripleTapGestureRec];

    // add text view to display logs
    self.tx_console = [UITextView.alloc initWithFrame:self.vw_container.bounds];
    self.tx_console.editable = NO;
    self.tx_console.selectable = NO;
    self.tx_console.backgroundColor = UIColor.clearColor;
    self.tx_console.textColor = [UIColor colorWithRed:215/255.0 green:201/255.0 blue:169/255.0 alpha:1.0];
    self.tx_console.font = [UIFont fontWithName:@"Menlo" size:10.0];
    [self.vw_container addSubview:self.tx_console];
    self.tx_console.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//    self.vw_container.alpha = 0;
    // state bools
    isBeingDragged = NO;
    isVisible = NO;
    
    NSString *tips = @"【拖动】:长按\n【拷贝】:单击两次 \n【清除】:单击三次： \n【隐藏/显示】:三指向下滑 \n【改变大小】:滑动\n";
    self.tx_console.text = [self.tx_console.text ?: @"" stringByAppendingString:tips];
}


- (void)readCompleted:(NSNotification *)notification
{
    [((NSFileHandle *)notification.object) readInBackgroundAndNotify];
    NSString* logs = [NSString.alloc initWithData:notification.userInfo[NSFileHandleNotificationDataItem] encoding:NSUTF8StringEncoding];
    [self addLog:logs];
}


- (void)addLog:(NSString *)logs {
    if (!logs) return;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        self.tx_console.text = [self.tx_console.text stringByAppendingFormat:@"%@\n", logs];
    });

    if (isBeingDragged)
        return;
    
    // deal with uitextview scrolling issues
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        BOOL shouldAutoScroll = (self.tx_console.contentOffset.y + self.tx_console.bounds.size.height * 2 >= self.tx_console.contentSize.height);
        if (shouldAutoScroll)
        {
            [self.tx_console scrollRangeToVisible:(NSRange){self.tx_console.text.length - 1, 0}];
            self.tx_console.scrollEnabled = NO;
            self.tx_console.scrollEnabled = YES;
        }
    });
}
#pragma mark -

- (void)onPan:(UIPanGestureRecognizer *)recognizer {
    static CGPoint startLocation;
    static CGRect startRect;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        startLocation = [recognizer locationInView:recognizer.view.superview];
        startRect = recognizer.view.frame;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint stopLocation = [recognizer locationInView:recognizer.view.superview];
        CGFloat dx = stopLocation.x - startLocation.x;
        CGFloat dy = stopLocation.y - startLocation.y;
        
        CGRect newr = CGRectMake(startRect.origin.x, startRect.origin.y, startRect.size.width + dx, startRect.size.height + dy);
        recognizer.view.frame = newr;
    }
}

- (void)onLongPress:(UIPanGestureRecognizer *)recognizer
{
    // drag drop
    UIView* topView = (UIView*)UIApplication.sharedApplication.keyWindow;
    static CGPoint diff;
    static CGPoint scrollContentOffset;

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        scrollContentOffset = self.tx_console.contentOffset;
        CGPoint startPoint = [recognizer locationInView:topView];
        diff = (CGPoint){self.vw_container.center.x - startPoint.x, self.vw_container.center.y - startPoint.y};
        isBeingDragged = YES;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint currentPoint = [recognizer locationInView:topView];
        CGPoint adjustedPoint = (CGPoint){currentPoint.x + diff.x, currentPoint.y + diff.y};
        self.vw_container.center = adjustedPoint;
        self.tx_console.contentOffset = scrollContentOffset;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        self.tx_console.contentOffset = scrollContentOffset;
        isBeingDragged = NO;
        CGPoint c = self.vw_container.center;
        CGPoint sc = self.vw_container.superview.center;
        if (fabs(c.x - sc.x) < 15) {
            c.x = sc.x;
            self.vw_container.center = c;
        }
    }
}


- (void)onDoubleTap:(UITapGestureRecognizer *)recognizer
{
    UIPasteboard.generalPasteboard.string = self.tx_console.text;
}


- (void)onTripleTap:(UITapGestureRecognizer *)recognizer
{
    [self clearConsole];
}


- (void)onSwipeDown:(UISwipeGestureRecognizer *)recognizer
{
    [self hideWithAnimation];
}


- (void)onSwipeUp:(UISwipeGestureRecognizer *)recognizer
{
    [self showWithAnimation];
}


#pragma mark -


- (void)hideWithAnimation
{
    if (!isVisible) {
        [self showWithAnimation];
        return;
    }

    isVisible = NO;

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{ self.vw_container.alpha = 0.0; } completion:nil];
}


- (void)showWithAnimation
{
    if (isVisible) {
        [self hideWithAnimation];
        return;
    }

    isVisible = YES;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{ self.vw_container.alpha = 0.7; }completion:nil];
}


- (void)clearConsole
{
    self.tx_console.text = @"";
}

@end
