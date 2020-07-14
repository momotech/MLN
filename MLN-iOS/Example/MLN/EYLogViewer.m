// erkanyildiz
// 20180310-2045+0900
//
// EYLogViewer.m
//
// https://github.com/erkanyildiz/EYLogViewer

#import "EYLogViewer.h"
#import <UIKit/UIKit.h>
#include <pthread.h>

@interface EYLogViewer ()
{
    BOOL isBeingDragged;
    BOOL isVisible;
}

@property (nonatomic) UITextView* tx_console;
@property (nonatomic) UIView* vw_container;
@end


@implementation EYLogViewer

+ (instancetype)sharedInstance
{
    static EYLogViewer* s_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ s_sharedInstance = self.new; });
    return s_sharedInstance;
}


+ (void)add
{
//    NSPipe* pipe = NSPipe.pipe;
//    NSFileHandle* fhr = pipe.fileHandleForReading;
//    dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stderr));
//    dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stdout));
//    [NSNotificationCenter.defaultCenter addObserver:EYLogViewer.sharedInstance selector:@selector(readCompleted:) name:NSFileHandleReadCompletionNotification object:fhr];
//    [fhr readInBackgroundAndNotify];

    [EYLogViewer.sharedInstance tryToFindTopWindow];
}


+ (void)show
{
    [EYLogViewer.sharedInstance showWithAnimation];
}


+ (void)hide
{
    [EYLogViewer.sharedInstance hideWithAnimation];
}


+ (void)clear
{
    [EYLogViewer.sharedInstance clearConsole];
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

    // add three finger swipe up gesture for showing
    UISwipeGestureRecognizer* swipeUpGestureRec = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(onSwipeUp:)];
    swipeUpGestureRec.direction = UISwipeGestureRecognizerDirectionUp;
    swipeUpGestureRec.numberOfTouchesRequired = 3;
    [UIApplication.sharedApplication.keyWindow addGestureRecognizer:swipeUpGestureRec];

    // add container view with border, shadow, background color etc...
    CGFloat const consoleHeightRatio = 0.4;   // 0.0 to 1.0 from bottom to top
    CGFloat const margin = 5.0;               // margin in pixels
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

    // state bools
    isBeingDragged = NO;
    isVisible = YES;
    
    NSString *tips = @"\n使用方式：\n单击两次：拷贝 \n单击三次：清除 \n长按：拖动 \n三指向上滑：显示 \n三指向下滑：隐藏\n";
    self.tx_console.text = [self.tx_console.text ?: @"" stringByAppendingString:tips];
}


- (void)readCompleted:(NSNotification *)notification
{
    [((NSFileHandle *)notification.object) readInBackgroundAndNotify];
    NSString* logs = [NSString.alloc initWithData:notification.userInfo[NSFileHandleNotificationDataItem] encoding:NSUTF8StringEncoding];
    [self addLog:logs];
}

- (void)addLog:(NSString *)logs {
    dispatch_async(dispatch_get_main_queue(), ^
    {
        self.tx_console.text = [self.tx_console.text stringByAppendingFormat:@"%@", logs];
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
    if (!isVisible)
        return;

    isVisible = NO;

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{ self.vw_container.alpha = 0.0; } completion:nil];
}


- (void)showWithAnimation
{
    if (isVisible)
        return;

    isVisible = YES;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{ self.vw_container.alpha = 0.7; }completion:nil];
}


- (void)clearConsole
{
    self.tx_console.text = @"";
}

@end
