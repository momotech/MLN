/**
  * Created by LuaView.
  * Copyright (c) 2017, Alibaba Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */

#import <UIKit/UIKit.h>
#import "MLNUIScrollViewConst.h"

@class MLNUIBlock;
@class MLNUILuaCore;
@interface UIScrollView (MLNUIRefresh)

- (instancetype)initWithRefreshEnable:(BOOL)refreshEnable loadEnable:(BOOL)loadEnable;
- (instancetype)initWithLuaCore:(MLNUILuaCore *)luaCore isHorizontal:(BOOL)isHorizontal;

@property (nonatomic, assign) BOOL mln_horizontal;
@property (nonatomic, assign) BOOL lua_refreshEnable;
@property (nonatomic, strong) MLNUIBlock *lua_refreshCallback;
- (BOOL)lua_isRefreshing;
- (void)lua_startRefreshing;
- (void)lua_stopRefreshing;
- (void)lua_startLoading;

@property (nonatomic, assign) BOOL lua_loadEnable;
// loading in advance value default 0, used value 0 ~ 1.0
@property (nonatomic, assign) CGFloat lua_loadahead;
@property (nonatomic, strong) MLNUIBlock *lua_loadCallback;
- (BOOL)lua_isLoading;
- (void)lua_stopLoading;
- (void)lua_noMoreData;
- (void)lua_resetLoading;
- (void)lua_loadError;
- (BOOL)lua_isNoMoreData;

@property (nonatomic, strong) UIView *mln_contentView;

@end

@interface UIScrollView (MLNUIScrolling)

@property (nonatomic, copy) MLNUIBlock *lua_scrollBeginCallback;
@property (nonatomic, copy) MLNUIBlock *lua_scrollingCallback;
@property (nonatomic, copy) MLNUIBlock *lua_endDraggingCallback;
@property (nonatomic, copy) MLNUIBlock *lua_startDeceleratingCallback;
@property (nonatomic, copy) MLNUIBlock *lua_scrollEndCallback;

- (void)lua_setContentInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;
- (void)lua_getContetnInset:(MLNUIBlock*)block;
- (void)lua_setScrollIndicatorInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom  left:(CGFloat)left;
- (void)lua_setContentOffsetWithAnimation:(CGPoint)point;
- (void)mln_setLuaScrollEnable:(BOOL)enable;
- (void)lua_addSubview:(UIView *)view;
- (void)lua_setContentOffset:(CGPoint)point;
- (CGPoint)lua_contentOffset;

@end

