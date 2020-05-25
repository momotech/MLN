//
//  MLNLinearLayoutNode.h
//
//
//  Created by MoMo on 2018/10/26.
//

#import "MLNLayoutContainerNode.h"
#import "MLNLinearLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNLinearLayoutNode : MLNLayoutContainerNode

@property (nonatomic, assign) MLNLayoutDirection direction;
@property (nonatomic, assign) BOOL reverse;

@end

NS_ASSUME_NONNULL_END
