//
//  MLNLayoutScrollContainerNode.h
//
//
//  Created by MoMo on 2018/12/13.
//

#import "MLNLayoutContainerNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNLayoutScrollContainerNode : MLNLayoutContainerNode

@property (nonatomic, assign) CGFloat measuredContentWidth;
@property (nonatomic, assign) CGFloat measuredContentHeight;
@property (nonatomic, assign, readonly) BOOL scrollHorizontal;

@end

NS_ASSUME_NONNULL_END
