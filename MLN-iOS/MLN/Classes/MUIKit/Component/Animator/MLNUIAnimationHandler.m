//
//  MLNUIAnimationHandler.m
//  MLNUI
//
//  Created by MoMo on 2019/5/21.
//

#import "MLNUIAnimationHandler.h"

@interface MLNUICADisplayLinkHandler : NSObject

@property (nonatomic, copy) void(^displayFrameCallback)(void);

@end
@implementation MLNUICADisplayLinkHandler

- (void)displayFrame
{
    if (self.displayFrameCallback) {
        self.displayFrameCallback();
    }
}

@end

@interface MLNUIAnimationHandler ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSMutableArray<id<MLNUIAnimationHandlerCallbackProtocol>> *callbacks;
@end
@implementation MLNUIAnimationHandler

static MLNUIAnimationHandler *_sharedHandler;
+ (instancetype)sharedHandler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHandler = [[MLNUIAnimationHandler alloc] init];
    });
    return _sharedHandler;
}

- (instancetype)init
{
    if (self = [super init]) {
        MLNUICADisplayLinkHandler *handler = [[MLNUICADisplayLinkHandler alloc] init];
        __weak typeof(self) wself = self;
        handler.displayFrameCallback = ^{
            __strong typeof(wself) sself = wself;
            [sself.callbacks enumerateObjectsUsingBlock:^(id<MLNUIAnimationHandlerCallbackProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CFTimeInterval time = CACurrentMediaTime();
                [obj doAnimationFrame:time];
            }];
        };
        _displayLink = [CADisplayLink displayLinkWithTarget:handler selector:@selector(displayFrame)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _callbacks = [NSMutableArray array];
    }
    return self;
}

- (void)pause
{
    _displayLink.paused = YES;
}

- (void)resume
{
    if (_displayLink.paused) {
         _displayLink.paused = NO;
    }
}

- (void)addCallback:(id<MLNUIAnimationHandlerCallbackProtocol>)callback
{
    if (callback && ![self.callbacks containsObject:callback]) {
        if (self.callbacks.count == 0) {
            [self resume];
        }
        [self.callbacks addObject:callback];
    }
}

- (void)removeCallback:(id<MLNUIAnimationHandlerCallbackProtocol>)callback
{
    if (callback) {
        [self.callbacks removeObject:callback];
        if (self.callbacks.count == 0) {
            [self pause];
        }
    }
}

- (void)removeAllCallbacks
{
    [self.callbacks removeAllObjects];
}

@end
