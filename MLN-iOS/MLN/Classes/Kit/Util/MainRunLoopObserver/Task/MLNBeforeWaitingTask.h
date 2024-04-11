//
//  MLNAnchorPointTask.h
//  MMLNua
//
//  Created by MoMo on 2019/3/19.
//

#import <UIKit/UIKit.h>
#import "MLNBeforeWaitingTaskProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNBeforeWaitingTask : NSObject <MLNBeforeWaitingTaskProtocol>

@property (nonatomic, copy) void(^taskCallback)(void);
+ (instancetype)taskWithCallback:(void(^)(void))callabck;

@end

NS_ASSUME_NONNULL_END
