//
//  MLNSpacerNode.h
//  MLN
//
//  Created by MOMO on 2020/3/27.
//

#import "MLNLayoutNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNSpacerNode : MLNLayoutNode

@property (nonatomic, assign, readonly) BOOL changedWidth;  // default is NO
@property (nonatomic, assign, readonly) BOOL changedHeight; // default is NO

@end

NS_ASSUME_NONNULL_END
