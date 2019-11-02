//
//  MLNFPSLabel.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/2.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNFPSLabel.h"
#import "MLNWeakTarget.h"

@interface MLNFPSLabel()
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSTimeInterval lastTime;
@end

@implementation MLNFPSLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _link = [CADisplayLink displayLinkWithTarget:[MLNWeakTarget weakTargetWithObject:self] selector:@selector(tick:)];
        [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)dealloc
{
    [_link invalidate];
}

- (void)tick:(CADisplayLink *)link
{
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _count ++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.textAlignment = NSTextAlignmentCenter;
    self.font = [UIFont systemFontOfSize:12];
    self.textColor = [UIColor whiteColor];
    self.text = [NSString stringWithFormat:@"%d FPS",(int)round(fps)];
}

@end
