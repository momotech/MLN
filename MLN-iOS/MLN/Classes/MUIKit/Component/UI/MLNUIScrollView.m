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

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore isHorizontal:(NSNumber *)isHorizontal isLinearContenView:(NSNumber *)isLinearContenView
{
    if (self = [super initWithFrame:CGRectZero]) {
        _innerScrollView = [[MLNUIInnerScrollView alloc] initWithMLNUILuaCore:luaCore direction:[isHorizontal boolValue] isLinearContenView:[isLinearContenView boolValue]];
        [super luaui_addSubview:_innerScrollView];
        _innerScrollView.luaui_node.widthType = MLNUILayoutMeasurementTypeMatchParent;
        _innerScrollView.luaui_node.heightType = MLNUILayoutMeasurementTypeMatchParent;
    }
    return self;
}

- (void)luaui_addSubview:(UIView *)view
{
    [self.innerScrollView luaui_addSubview:view];
}

- (void)luaui_removeAllSubViews {
    [self.innerScrollView luaui_removeAllSubViews];
}

- (void)setLuaui_width:(CGFloat)luaui_width
{
    [super setLuaui_width:luaui_width];
    if (self.luaui_node.isDirty) {
        [self.innerScrollView luaui_needLayout];
        [self.innerScrollView updateContentViewLayoutIfNeed];
    }
}

- (void)setLuaui_height:(CGFloat)luaui_height
{
    [super setLuaui_height:luaui_height];
    if (self.luaui_node.isDirty) {
        [self.innerScrollView luaui_needLayout];
        [self.innerScrollView updateContentViewLayoutIfNeed];
    }
}

- (void)setLuaui_ContentSize:(CGSize)contentSize
{
    MLNUIKitLuaAssert(NO, @"ScrollView 'contentSize' setter is deprecated");
    self.innerScrollView.contentSize = contentSize;
    [self.innerScrollView recalculContentSizeIfNeed];
}

- (CGSize)luaui_contentSize
{
    return self.innerScrollView.contentSize;
}

- (void)setLuaui_loadahead:(CGFloat)loadahead
{
    [self.innerScrollView setLuaui_loadahead:loadahead];
}

- (CGFloat)luaui_loadahead
{
    return self.innerScrollView.luaui_loadahead;
}

- (void)setLuaui_ContentOffset:(CGPoint)point
{
    [self.innerScrollView luaui_setContentOffset:point];
}

- (CGPoint)luaui_contentOffset
{
    return [self.innerScrollView luaui_contentOffset];
}

- (void)setLuaui_ScrollEnabled:(BOOL)scrollEnable
{
    [self.innerScrollView setScrollEnabled:scrollEnable];
}

- (BOOL)luaui_isScrollEnabled
{
    return self.innerScrollView.isScrollEnabled;
}

- (void)setLuaui_Bounces:(BOOL)bounces
{
    [self.innerScrollView setBounces:bounces];
}

- (BOOL)luaui_bounces
{
    return self.innerScrollView.bounces;
}

- (void)setLuaui_showsHorizontalScrollIndicator:(BOOL)show
{
    self.innerScrollView.showsHorizontalScrollIndicator = show;
}

- (BOOL)luaui_showsHorizontalScrollIndicator
{
    return self.innerScrollView.showsHorizontalScrollIndicator;
}

- (void)setLuaui_showsVerticalScrollIndicator:(BOOL)show
{
    self.innerScrollView.showsVerticalScrollIndicator = show;
}

- (BOOL)luaui_showsVerticalScrollIndicator
{
    return self.innerScrollView.showsVerticalScrollIndicator;
}

- (void)setLuaui_alwaysBounceHorizontal:(BOOL)alwaysBounceHorizontal
{
    self.innerScrollView.alwaysBounceHorizontal = alwaysBounceHorizontal;
}

- (BOOL)luaui_alwaysBounceHorizontal
{
    return self.innerScrollView.alwaysBounceHorizontal;
}

- (void)setLuaui_alwaysBounceVertical:(BOOL)alwaysBounceVertical
{
    self.innerScrollView.alwaysBounceVertical = alwaysBounceVertical;
}

- (BOOL)luaui_alwaysBounceVertical
{
    return self.innerScrollView.alwaysBounceVertical;
}

- (void)setLuaui_scrollBeginCallback:(MLNUIBlock *)callback
{
    self.innerScrollView.luaui_scrollBeginCallback = callback;
}

- (void)setLuaui_scrollingCallback:(MLNUIBlock *)callback
{
    self.innerScrollView.luaui_scrollingCallback = callback;
}

- (void)setLuaui_endDraggingCallback:(MLNUIBlock *)callback
{
    self.innerScrollView.luaui_endDraggingCallback = callback;
}

- (void)setLuaui_startDeceleratingCallback:(MLNUIBlock *)callback
{
    self.innerScrollView.luaui_startDeceleratingCallback = callback;
}

- (void)setLuaui_scrollEndCallback:(MLNUIBlock *)callback
{
    self.innerScrollView.luaui_scrollEndCallback = callback;
}

- (void)luaui_setContentInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    [self.innerScrollView luaui_setContentInset:top right:right bottom:bottom left:left];
}

- (void)luaui_getContetnInset:(MLNUIBlock*)block
{
    [self.innerScrollView luaui_getContetnInset:block];
}

- (void)luaui_setScrollIndicatorInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom  left:(CGFloat)left
{
    [self.innerScrollView luaui_setScrollIndicatorInset:top right:right bottom:bottom left:left];
}

- (void)luaui_setContentOffsetWithAnimation:(CGPoint)point
{
    [self.innerScrollView luaui_setContentOffsetWithAnimation:point];
}

- (void)mlnui_setLuaScrollEnable:(BOOL)scrollEnable
{
    [self.innerScrollView mlnui_setLuaScrollEnable:scrollEnable];
}

- (void)mlnui_setFlingSpeed:(CGFloat)speed
{
    self.innerScrollView.decelerationRate = speed;
}

- (CGFloat)mlnui_flingSpeed
{
    return self.innerScrollView.decelerationRate;
}

- (void)mlnui_setPagingEnable:(BOOL)pagingEnabled
{
    self.innerScrollView.pagingEnabled = pagingEnabled;
}

- (BOOL)mlnui_pagingEnabled
{
    return self.innerScrollView.pagingEnabled;
}


#pragma mark - Override
- (BOOL)luaui_layoutEnable
{
    return YES;
}

- (BOOL)luaui_isContainer
{
    return YES;
}

#pragma mark - Export For Lua
LUAUI_EXPORT_VIEW_BEGIN(MLNUIScrollView)
LUAUI_EXPORT_VIEW_PROPERTY(contentSize, "setLuaui_ContentSize:", "luaui_contentSize", MLNUIScrollView)
LUAUI_EXPORT_VIEW_PROPERTY(loadThreshold, "setLuaui_loadahead:", "luaui_loadahead", MLNUIScrollView)
LUAUI_EXPORT_VIEW_PROPERTY(contentOffset, "setLuaui_ContentOffset:", "luaui_contentOffset", MLNUIScrollView)
LUAUI_EXPORT_VIEW_PROPERTY(scrollEnabled, "setLuaui_ScrollEnabled:", "luaui_isScrollEnabled", MLNUIScrollView)
LUAUI_EXPORT_VIEW_PROPERTY(i_bounces, "setLuaui_Bounces:", "luaui_bounces", MLNUIScrollView)
LUAUI_EXPORT_VIEW_PROPERTY(showsHorizontalScrollIndicator, "setLuaui_showsHorizontalScrollIndicator:", "luaui_showsHorizontalScrollIndicator", MLNUIScrollView)
LUAUI_EXPORT_VIEW_PROPERTY(showsVerticalScrollIndicator, "setLuaui_showsVerticalScrollIndicator:", "luaui_showsVerticalScrollIndicator", MLNUIScrollView)
LUAUI_EXPORT_VIEW_PROPERTY(i_bounceHorizontal, "setLuaui_alwaysBounceHorizontal:", "luaui_alwaysBounceHorizontal", MLNUIScrollView)
LUAUI_EXPORT_VIEW_PROPERTY(i_bounceVertical, "setLuaui_alwaysBounceVertical:", "luaui_alwaysBounceVertical", MLNUIScrollView)
LUAUI_EXPORT_VIEW_PROPERTY(a_flingSpeed, "mlnui_setFlingSpeed:", "mlnui_flingSpeed" , MLNUIScrollView)
LUAUI_EXPORT_VIEW_PROPERTY(i_pagingEnabled, "mlnui_setPagingEnable:", "mlnui_pagingEnabled" , MLNUIScrollView)
LUAUI_EXPORT_VIEW_METHOD(setScrollBeginCallback, "setLuaui_scrollBeginCallback:",MLNUIScrollView)
LUAUI_EXPORT_VIEW_METHOD(setScrollingCallback, "setLuaui_scrollingCallback:",MLNUIScrollView)
LUAUI_EXPORT_VIEW_METHOD(setEndDraggingCallback, "setLuaui_endDraggingCallback:",MLNUIScrollView)
LUAUI_EXPORT_VIEW_METHOD(setStartDeceleratingCallback, "setLuaui_startDeceleratingCallback:",MLNUIScrollView)
LUAUI_EXPORT_VIEW_METHOD(setScrollEndCallback, "setLuaui_scrollEndCallback:",MLNUIScrollView)
LUAUI_EXPORT_VIEW_METHOD(setContentInset, "luaui_setContentInset:right:bottom:left:", MLNUIScrollView)
LUAUI_EXPORT_VIEW_METHOD(getContentInset, "luaui_getContetnInset:", MLNUIScrollView)
LUAUI_EXPORT_VIEW_METHOD(setScrollIndicatorInset, "luaui_setScrollIndicatorInset:right:bottom:left:", MLNUIScrollView)
LUAUI_EXPORT_VIEW_METHOD(setOffsetWithAnim, "luaui_setContentOffsetWithAnimation:", MLNUIScrollView)
LUAUI_EXPORT_VIEW_METHOD(setScrollEnable, "mlnui_setLuaScrollEnable:", MLNUIScrollView)
LUAUI_EXPORT_VIEW_END(MLNUIScrollView, ScrollView, YES, "MLNUIView", "initWithMLNUILuaCore:isHorizontal:isLinearContenView:")

@end

