//
//  MLNMainRunLoopObserver.h
//
//
//  Created by MoMo on 2018/10/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNMainRunLoopObserver : NSObject

- (void)beginForBeforeWaiting:(CFIndex)order repeats:(BOOL)repeats callback:(void(^)(void))callback;
- (void)beginForActivity:(CFRunLoopActivity)activity repeats:(BOOL)repeats order:(CFIndex)order callback:(void(^)(CFRunLoopActivity activity))callback;
- (void)end;

@end

NS_ASSUME_NONNULL_END
