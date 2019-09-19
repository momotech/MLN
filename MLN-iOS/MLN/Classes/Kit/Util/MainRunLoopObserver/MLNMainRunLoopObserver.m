//
//  MLNMainRunLoopObserver.m
//
//
//  Created by MoMo on 2018/10/24.
//

#import "MLNMainRunLoopObserver.h"

@interface MLNMainRunLoopObserver ()

@property (nonatomic, assign) CFRunLoopObserverRef obs;

@end
@implementation MLNMainRunLoopObserver

- (void)dealloc
{
    [self end];
}

- (void)beginForBeforeWaiting:(CFIndex)order repeats:(BOOL)repeats callback:(void(^)(void))callback
{
    if (!callback) return;
    [self beginForActivity:kCFRunLoopBeforeWaiting repeats:repeats order:order callback:^(CFRunLoopActivity activity) {
        if (callback && activity == kCFRunLoopBeforeWaiting) {
            callback();
        }
    }];
}

- (void)beginForActivity:(CFRunLoopActivity)activity repeats:(BOOL)repeats order:(CFIndex)order callback:(void(^)(CFRunLoopActivity activity))callback
{
    if (!callback) return;
    _obs = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, activity, repeats, order, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        if (callback) {
            callback(activity);
        }
    });
    CFRunLoopAddObserver(CFRunLoopGetMain(), _obs, kCFRunLoopCommonModes);
}

- (void)end
{
    if (_obs) {
        if (CFRunLoopContainsObserver(CFRunLoopGetMain(), _obs, kCFRunLoopCommonModes)) {
            CFRunLoopRemoveObserver(CFRunLoopGetMain(), _obs, kCFRunLoopCommonModes);
        }
        CFRelease(_obs);
        _obs = nil;
    }
}

@end
