//
//  MLNUIScrollView.m
//  Expecta
//
//  Created by MoMo on 2018/7/5.
//

#import "MLNUIScrollView.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "UIScrollView+MLNUIKit.h"
#import "MLNUIScrollViewDelegate.h"
#import "UIView+MLNUILayout.h"
#import "MLNUILinearLayout.h"
#import "UIView+MLNUIKit.h"
#import "MLNUILuaCore.h"
#import "MLNUILayoutScrollContainerNode.h"
#import "MLNUIInnerScrollView.h"
#import "MLNUIViewConst.h"

@interface MLNUIScrollView()

@property (nonatomic, strong) MLNUIInnerScrollView *innerScrollView;

@end

@implementation MLNUIScrollView

- (instancetype)initWithLuaCore:(MLNUILuaCore *)luaCore isHorizontal:(NSNumber *)isHorizontal isLinearContenView:(NSNumber *)isLinearContenView
{
    if (self = [super initWithFrame:CGRectZero]) {
        _innerScrollView = [[MLNUIInnerScrollView alloc] initWithLuaCore:luaCore direction:[isHorizontal boolValue] isLinearContenView:[isLinearContenView boolValue]];
        [super lua_addSubview:_innerScrollView];
        _innerScrollView.lua_node.widthType = MLNUILayoutMeasurementTypeMatchParent;
        _innerScrollView.lua_node.heightType = MLNUILayoutMeasurementTypeMatchParent;
    }
    return self;
}

- (void)lua_addSubview:(UIView *)view
{
    [self.innerScrollView lua_addSubview:view];
}

- (void)setLua_width:(CGFloat)lua_width
{
    [super setLua_width:lua_width];
    if (self.lua_node.isDirty) {
        [self.innerScrollView lua_needLayout];
        [self.innerScrollView updateContentViewLayoutIfNeed];
    }
}

- (void)setLua_height:(CGFloat)lua_height
{
    [super setLua_height:lua_height];
    if (self.lua_node.isDirty) {
        [self.innerScrollView lua_needLayout];
        [self.innerScrollView updateContentViewLayoutIfNeed];
    }
}

- (void)setLua_ContentSize:(CGSize)contentSize
{
    MLNUIKitLuaAssert(NO, @"ScrollView 'contentSize' setter is deprecated");
    self.innerScrollView.contentSize = contentSize;
    [self.innerScrollView recalculContentSizeIfNeed];
}

- (CGSize)lua_contentSize
{
    return self.innerScrollView.contentSize;
}

- (void)setLua_loadahead:(CGFloat)loadahead
{
    [self.innerScrollView setLua_loadahead:loadahead];
}

- (CGFloat)lua_loadahead
{
    return self.innerScrollView.lua_loadahead;
}

- (void)setLua_ContentOffset:(CGPoint)point
{
    [self.innerScrollView lua_setContentOffset:point];
}

- (CGPoint)lua_contentOffset
{
    return [self.innerScrollView lua_contentOffset];
}

- (void)setLua_ScrollEnabled:(BOOL)scrollEnable
{
    [self.innerScrollView setScrollEnabled:scrollEnable];
}

- (BOOL)lua_isScrollEnabled
{
    return self.innerScrollView.isScrollEnabled;
}

- (void)setLua_Bounces:(BOOL)bounces
{
    [self.innerScrollView setBounces:bounces];
}

- (BOOL)lua_bounces
{
    return self.innerScrollView.bounces;
}

- (void)setLua_showsHorizontalScrollIndicator:(BOOL)show
{
    self.innerScrollView.showsHorizontalScrollIndicator = show;
}

- (BOOL)lua_showsHorizontalScrollIndicator
{
    return self.innerScrollView.showsHorizontalScrollIndicator;
}

- (void)setLua_showsVerticalScrollIndicator:(BOOL)show
{
    self.innerScrollView.showsVerticalScrollIndicator = show;
}

- (BOOL)lua_showsVerticalScrollIndicator
{
    return self.innerScrollView.showsVerticalScrollIndicator;
}

- (void)setLua_alwaysBounceHorizontal:(BOOL)alwaysBounceHorizontal
{
    self.innerScrollView.alwaysBounceHorizontal = alwaysBounceHorizontal;
}

- (BOOL)lua_alwaysBounceHorizontal
{
    return self.innerScrollView.alwaysBounceHorizontal;
}

- (void)setLua_alwaysBounceVertical:(BOOL)alwaysBounceVertical
{
    self.innerScrollView.alwaysBounceVertical = alwaysBounceVertical;
}

- (BOOL)lua_alwaysBounceVertical
{
    return self.innerScrollView.alwaysBounceVertical;
}

- (void)setLua_scrollBeginCallback:(MLNUIBlock *)callback
{
    self.innerScrollView.lua_scrollBeginCallback = callback;
}

- (void)setLua_scrollingCallback:(MLNUIBlock *)callback
{
    self.innerScrollView.lua_scrollingCallback = callback;
}

- (void)setLua_endDraggingCallback:(MLNUIBlock *)callback
{
    self.innerScrollView.lua_endDraggingCallback = callback;
}

- (void)setLua_startDeceleratingCallback:(MLNUIBlock *)callback
{
    self.innerScrollView.lua_startDeceleratingCallback = callback;
}

- (void)setLua_scrollEndCallback:(MLNUIBlock *)callback
{
    self.innerScrollView.lua_scrollEndCallback = callback;
}

- (void)lua_setContentInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    [self.innerScrollView lua_setContentInset:top right:right bottom:bottom left:left];
}

- (void)lua_getContetnInset:(MLNUIBlock*)block
{
    [self.innerScrollView lua_getContetnInset:block];
}

- (void)lua_setScrollIndicatorInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom  left:(CGFloat)left
{
    [self.innerScrollView lua_setScrollIndicatorInset:top right:right bottom:bottom left:left];
}

- (void)lua_setContentOffsetWithAnimation:(CGPoint)point
{
    [self.innerScrollView lua_setContentOffsetWithAnimation:point];
}

- (void)mln_setLuaScrollEnable:(BOOL)scrollEnable
{
    [self.innerScrollView mln_setLuaScrollEnable:scrollEnable];
}

- (void)mln_setFlingSpeed:(CGFloat)speed
{
    self.innerScrollView.decelerationRate = speed;
}

- (CGFloat)mln_flingSpeed
{
    return self.innerScrollView.decelerationRate;
}

- (void)mln_setPagingEnable:(BOOL)pagingEnabled
{
    self.innerScrollView.pagingEnabled = pagingEnabled;
}

- (BOOL)mln_pagingEnabled
{
    return self.innerScrollView.pagingEnabled;
}


#pragma mark - Override
- (BOOL)lua_layoutEnable
{
    return YES;
}

- (BOOL)lua_isContainer
{
    return YES;
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNUIScrollView)
LUA_EXPORT_VIEW_PROPERTY(contentSize, "setLua_ContentSize:", "lua_contentSize", MLNUIScrollView)
LUA_EXPORT_VIEW_PROPERTY(loadThreshold, "setLua_loadahead:", "lua_loadahead", MLNUIScrollView)
LUA_EXPORT_VIEW_PROPERTY(contentOffset, "setLua_ContentOffset:", "lua_contentOffset", MLNUIScrollView)
LUA_EXPORT_VIEW_PROPERTY(scrollEnabled, "setLua_ScrollEnabled:", "lua_isScrollEnabled", MLNUIScrollView)
LUA_EXPORT_VIEW_PROPERTY(i_bounces, "setLua_Bounces:", "lua_bounces", MLNUIScrollView)
LUA_EXPORT_VIEW_PROPERTY(showsHorizontalScrollIndicator, "setLua_showsHorizontalScrollIndicator:", "lua_showsHorizontalScrollIndicator", MLNUIScrollView)
LUA_EXPORT_VIEW_PROPERTY(showsVerticalScrollIndicator, "setLua_showsVerticalScrollIndicator:", "lua_showsVerticalScrollIndicator", MLNUIScrollView)
LUA_EXPORT_VIEW_PROPERTY(i_bounceHorizontal, "setLua_alwaysBounceHorizontal:", "lua_alwaysBounceHorizontal", MLNUIScrollView)
LUA_EXPORT_VIEW_PROPERTY(i_bounceVertical, "setLua_alwaysBounceVertical:", "lua_alwaysBounceVertical", MLNUIScrollView)
LUA_EXPORT_VIEW_PROPERTY(a_flingSpeed, "mln_setFlingSpeed:", "mln_flingSpeed" , MLNUIScrollView)
LUA_EXPORT_VIEW_PROPERTY(i_pagingEnabled, "mln_setPagingEnable:", "mln_pagingEnabled" , MLNUIScrollView)
LUA_EXPORT_VIEW_METHOD(setScrollBeginCallback, "setLua_scrollBeginCallback:",MLNUIScrollView)
LUA_EXPORT_VIEW_METHOD(setScrollingCallback, "setLua_scrollingCallback:",MLNUIScrollView)
LUA_EXPORT_VIEW_METHOD(setEndDraggingCallback, "setLua_endDraggingCallback:",MLNUIScrollView)
LUA_EXPORT_VIEW_METHOD(setStartDeceleratingCallback, "setLua_startDeceleratingCallback:",MLNUIScrollView)
LUA_EXPORT_VIEW_METHOD(setScrollEndCallback, "setLua_scrollEndCallback:",MLNUIScrollView)
LUA_EXPORT_VIEW_METHOD(setContentInset, "lua_setContentInset:right:bottom:left:", MLNUIScrollView)
LUA_EXPORT_VIEW_METHOD(getContentInset, "lua_getContetnInset:", MLNUIScrollView)
LUA_EXPORT_VIEW_METHOD(setScrollIndicatorInset, "lua_setScrollIndicatorInset:right:bottom:left:", MLNUIScrollView)
LUA_EXPORT_VIEW_METHOD(setOffsetWithAnim, "lua_setContentOffsetWithAnimation:", MLNUIScrollView)
LUA_EXPORT_VIEW_METHOD(setScrollEnable, "mln_setLuaScrollEnable:", MLNUIScrollView)
LUA_EXPORT_VIEW_END(MLNUIScrollView, ScrollView, YES, "MLNUIView", "initWithLuaCore:isHorizontal:isLinearContenView:")

@end

