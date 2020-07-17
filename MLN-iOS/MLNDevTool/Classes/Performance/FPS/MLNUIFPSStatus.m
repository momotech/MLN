//
//  MLNUIFPSStatus.m
//  MLNDevTool
//
//  Created by Dongpeng Dai on 2020/7/9.
//

#import "MLNUIFPSStatus.h"


@interface MLNUIFPSStatus (){
    CADisplayLink *displayLink;
    NSTimeInterval lastTime;
    NSUInteger count;
}
@property(nonatomic,copy) void (^fpsHandler)(NSInteger fpsValue);

@end

@implementation MLNUIFPSStatus

- (void)dealloc {
    [displayLink setPaused:YES];
    [displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

+ (MLNUIFPSStatus *)sharedInstance {
    static MLNUIFPSStatus *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MLNUIFPSStatus alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationDidBecomeActiveNotification)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationWillResignActiveNotification)
                                                     name: UIApplicationWillResignActiveNotification
                                                   object: nil];
        
        // Track FPS using display link
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
        [displayLink setPaused:YES];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        // self.fpsLabel
        self.fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width-50)/2+50, 0, 50, 20)];
        BOOL isiPhoneX = (([[UIScreen mainScreen] bounds].size.width == 375.f && [[UIScreen mainScreen] bounds].size.height == 812.f) || ([[UIScreen mainScreen] bounds].size.height == 375.f && [[UIScreen mainScreen] bounds].size.width == 812.f));
        if (isiPhoneX) {
            self.fpsLabel.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width-50)/2+50, 24, 50, 20);
        }
        self.fpsLabel.font=[UIFont boldSystemFontOfSize:12];
        self.fpsLabel.textColor=[UIColor colorWithRed:0.33 green:0.84 blue:0.43 alpha:1.00];
        self.fpsLabel.backgroundColor=[UIColor clearColor];
        self.fpsLabel.textAlignment=NSTextAlignmentRight;
        self.fpsLabel.tag=101;

    }
    return self;
}

- (void)displayLinkTick:(CADisplayLink *)link {
    if (lastTime == 0) {
        lastTime = link.timestamp;
        return;
    }
    
    UIView *superView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    if (superView.subviews.lastObject != self.fpsLabel) {
        [superView bringSubviewToFront:self.fpsLabel];
    }
    
    count++;
    NSTimeInterval interval = link.timestamp - lastTime;
    if (interval < 1) return;
    lastTime = link.timestamp;
    float fps = count / interval;
    count = 0;
    
    NSString *text = [NSString stringWithFormat:@"%d FPS",(int)round(fps)];
    [self.fpsLabel setText: text];
    
    CGFloat progress = MAX(fps / 60.0, 3/60.0);
    
    UIColor *color = [UIColor colorWithHue:0.6 * (progress - .3) saturation:1 brightness:.5 alpha:1];
    self.fpsLabel.textColor = color;
    
    if (_fpsHandler) {
        _fpsHandler((int)round(fps));
    }
}

- (void)open {
    
    NSArray *rootVCViewSubViews=[[UIApplication sharedApplication].delegate window].rootViewController.view.subviews;
    for (UIView *label in rootVCViewSubViews) {
        if ([label isKindOfClass:[UILabel class]]&& label.tag==101) {
            return;
        }
    }

    [displayLink setPaused:NO];
    [[((NSObject <UIApplicationDelegate> *)([UIApplication sharedApplication].delegate)) window].rootViewController.view addSubview:self.fpsLabel];
}

- (void)openWithHandler:(void (^)(NSInteger fpsValue))handler{
    [[MLNUIFPSStatus sharedInstance] open];
    _fpsHandler=handler;
}

- (void)close {
    
    [displayLink setPaused:YES];

    NSArray *rootVCViewSubViews=[[UIApplication sharedApplication].delegate window].rootViewController.view.subviews;
    for (UIView *label in rootVCViewSubViews) {
        if ([label isKindOfClass:[UILabel class]]&& label.tag==101) {
            [label removeFromSuperview];
            return;
        }
    }
    
}

- (void)applicationDidBecomeActiveNotification {
    [displayLink setPaused:NO];
}

- (void)applicationWillResignActiveNotification {
    [displayLink setPaused:YES];
}

@end
