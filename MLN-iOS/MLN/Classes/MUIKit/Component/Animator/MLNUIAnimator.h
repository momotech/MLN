//
//  Animator.h
//  MLNUI
//
//  Created by MoMo on 2019/5/21.
//

#import <UIKit/UIKit.h>
#import "MLNUIEntityExportProtocol.h"
#import "MLNUIAnimationHandlerCallbackProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 动画执行器，按照屏幕刷新频率给予监听者回调及执行的百分比
 */
@interface MLNUIAnimator : NSObject <NSCopying, MLNUIEntityExportProtocol, MLNUIAnimationHandlerCallbackProtocol>

@end

NS_ASSUME_NONNULL_END
