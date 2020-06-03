//
//  MLNUITransform.h
//  
//
//  Created by MoMo on 2019/3/14.
//

#import <UIKit/UIKit.h>
#import "MLNUIBeforeWaitingTaskProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUITransformTask : NSObject <MLNUIBeforeWaitingTaskProtocol>

/**
 执行Transform的视图
 */
@property (nonatomic, weak, readonly) UIView *target;
@property (nonatomic) CGAffineTransform transform;

/**
 创建Transform任务

 @param targetView 执行Transform的视图
 @return Transform任务
 */
- (instancetype)initWithTargetView:(UIView *)targetView;

@end

NS_ASSUME_NONNULL_END
