//
//  MLNInterpolator.h
//  MLN
//
//  Created by MoMo on 2019/9/4.
//

#import <UIKit/UIKit.h>

#ifndef MLNInterpolatorProtocol_h
#define MLNInterpolatorProtocol_h

/**
 动画差值器协议
 */
@protocol MLNInterpolatorProtocol <NSObject>

/**
 获取当前差值

 @param progress 当前进度的百分比
 @return 计算后得到的百分比
 */
- (CGFloat)getInterpolation:(CGFloat)progress;

@end

#endif /* MLNInterpolatorProtocol_h */
