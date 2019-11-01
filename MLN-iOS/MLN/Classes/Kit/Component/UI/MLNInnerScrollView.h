//
//  MLNInnerScrollView.h
//  MLN
//
//  Created by MoMo on 2019/11/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNLuaCore;
@interface MLNInnerScrollView : UIScrollView

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore direction:(BOOL)horizontal isLinearContenView:(BOOL)isLinearContenView;
- (void)updateContentViewLayoutIfNeed;
- (void)recalculContentSizeIfNeed;

@end

NS_ASSUME_NONNULL_END
