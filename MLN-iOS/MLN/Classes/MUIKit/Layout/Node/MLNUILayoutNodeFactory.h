//
//  MLNUILayoutNodeFactory.h
//
//
//  Created by MoMo on 2018/12/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNUILayoutNode;
@interface MLNUILayoutNodeFactory : NSObject

+ (MLNUILayoutNode *)createNodeWithTargetView:(UIView *)aView;

@end

NS_ASSUME_NONNULL_END
