//
//  MLNUIAnchorPointTask.h
//  MMLNUIua
//
//  Created by MoMo on 2019/3/19.
//

#import <UIKit/UIKit.h>
#import "MLNUIBeforeWaitingTaskProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIBeforeWaitingTask : NSObject <MLNUIBeforeWaitingTaskProtocol>

@property (nonatomic, copy) void(^taskCallback)(void);
+ (instancetype)taskWithCallback:(void(^)(void))callabck;

@end

NS_ASSUME_NONNULL_END
