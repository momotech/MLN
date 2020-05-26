//
//  MLNUILayoutScrollContainerNode.h
//
//
//  Created by MoMo on 2018/12/13.
//

#import "MLNUILayoutContainerNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUILayoutScrollContainerNode : MLNUILayoutContainerNode

@property (nonatomic, assign) CGFloat measuredContentWidth;
@property (nonatomic, assign) CGFloat measuredContentHeight;
@property (nonatomic, assign, readonly) BOOL scrollHorizontal;

@end

NS_ASSUME_NONNULL_END
