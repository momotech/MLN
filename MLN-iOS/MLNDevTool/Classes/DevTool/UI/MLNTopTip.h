//
//  MLNTopTipView.h
//  MLNDebugTool
//
//  Created by MoMo on 2019/9/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNTopTip : NSObject

+ (void)show:(NSString *)msg duration:(NSTimeInterval)duration;
+ (void)hidden:(NSString *)msg duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
+ (void)tip:(NSString *)msg duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

@end

NS_ASSUME_NONNULL_END
