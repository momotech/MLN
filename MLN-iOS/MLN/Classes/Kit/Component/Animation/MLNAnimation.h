//
//  MLNAnimation.h
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/9.
//

#import <UIKit/UIKit.h>
#import "MLNEntityExportProtocol.h"
#import "MLNBeforeWaitingTaskProtocol.h"

@interface MLNAnimation : NSObject <MLNEntityExportProtocol, MLNBeforeWaitingTaskProtocol>

- (void)callAnimationDidStart;
- (void)callAnimationDidStopWith:(BOOL)flag;

@end
