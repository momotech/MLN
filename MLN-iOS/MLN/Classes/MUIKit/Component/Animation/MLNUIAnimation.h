//
//  MLNUIAnimation.h
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/9.
//

#import <UIKit/UIKit.h>
#import "MLNUIEntityExportProtocol.h"
#import "MLNUIBeforeWaitingTaskProtocol.h"

@interface MLNUIAnimation : NSObject <MLNUIEntityExportProtocol, MLNUIBeforeWaitingTaskProtocol>

- (void)callAnimationDidStart;
- (void)callAnimationDidStopWith:(BOOL)flag;

@end
