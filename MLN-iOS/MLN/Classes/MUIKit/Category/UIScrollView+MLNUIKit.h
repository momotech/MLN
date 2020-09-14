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
@class MLNUIPlaneStack;
@interface UIScrollView (MLNUIRefresh)

- (instancetype)initWithMLNUIRefreshEnable:(BOOL)refreshEnable loadEnable:(BOOL)loadEnable;
- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore isHorizontal:(BOOL)isHorizontal;

@property (nonatomic, assign) BOOL mlnui_horizontal;
@property (nonatomic, assign) BOOL luaui_refreshEnable;
@property (nonatomic, strong) MLNUIBlock *luaui_refreshCallback;
- (BOOL)luaui_isRefreshing;
- (void)luaui_startRefreshing;
- (void)luaui_stopRefreshing;
- (void)luaui_startLoading;

@property (nonatomic, assign) BOOL luaui_loadEnable;
// loading in advance value default 0, used value 0 ~ 1.0
@property (nonatomic, assign) CGFloat luaui_loadahead;
@property (nonatomic, strong) MLNUIBlock *luaui_loadCallback;
- (BOOL)luaui_isLoading;
- (void)luaui_stopLoading;
- (void)luaui_noMoreData;
- (void)luaui_resetLoading;
- (void)luaui_loadError;
- (BOOL)luaui_isNoMoreData;

@property (nonatomic, strong) UIView *mlnui_contentView;

@end

@interface UIScrollView (MLNUIScrolling)

@property (nonatomic, copy) MLNUIBlock *luaui_scrollBeginCallback;
@property (nonatomic, copy) MLNUIBlock *luaui_scrollingCallback;
@property (nonatomic, copy) MLNUIBlock *luaui_scrollWillEndDraggingCallback;
@property (nonatomic, copy) MLNUIBlock *luaui_endDraggingCallback;
@property (nonatomic, copy) MLNUIBlock *luaui_startDeceleratingCallback;
@property (nonatomic, copy) MLNUIBlock *luaui_scrollEndCallback;
@property (nonatomic, assign) BOOL luaui_disallowFling;

- (void)luaui_setContentInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;
- (void)luaui_getContetnInset:(MLNUIBlock*)block;
- (void)luaui_setScrollIndicatorInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom  left:(CGFloat)left;
- (void)luaui_setContentOffsetWithAnimation:(CGPoint)point;
- (void)mlnui_setLuaScrollEnable:(BOOL)enable;
- (void)luaui_addSubview:(UIView *)view;
- (void)luaui_setContentOffset:(CGPoint)point;
- (CGPoint)luaui_contentOffset;

@end

