//
//  MLNLayoutNodeFactory.h
//
//
//  Created by MoMo on 2018/12/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNLayoutNode;
@interface MLNLayoutNodeFactory : NSObject

+ (MLNLayoutNode *)createNodeWithTargetView:(UIView *)aView;

@end

NS_ASSUME_NONNULL_END
