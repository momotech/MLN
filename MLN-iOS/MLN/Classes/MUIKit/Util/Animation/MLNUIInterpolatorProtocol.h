//
//  MLNUIInterpolator.h
//  MLNUI
//
//  Created by MoMo on 2019/9/4.
//

#import <UIKit/UIKit.h>

#ifndef MLNUIInterpolatorProtocol_h
#define MLNUIInterpolatorProtocol_h

/**
 动画差值器协议
 */
@protocol MLNUIInterpolatorProtocol <NSObject>

/**
 获取当前差值

 @param progress 当前进度的百分比
 @return 计算后得到的百分比
 */
- (CGFloat)getInterpolation:(CGFloat)progress;

@end

#endif /* MLNUIInterpolatorProtocol_h */
