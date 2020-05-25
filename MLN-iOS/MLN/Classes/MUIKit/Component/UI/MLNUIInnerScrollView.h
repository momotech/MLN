//
//  MLNUIInnerScrollView.h
//  MLNUI
//
//  Created by MoMo on 2019/11/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNUILuaCore;
@interface MLNUIInnerScrollView : UIScrollView

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore direction:(BOOL)horizontal isLinearContenView:(BOOL)isLinearContenView;
- (void)updateContentViewLayoutIfNeed;
- (void)recalculContentSizeIfNeed;

@end

NS_ASSUME_NONNULL_END
