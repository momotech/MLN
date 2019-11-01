//
//  MLNScrollView.m
//  Expecta
//
//  Created by MoMo on 2018/7/5.
//

#import "MLNScrollView.h"
#import "MLNKitHeader.h"
#import "MLNViewExporterMacro.h"
#import "UIScrollView+MLNKit.h"
#import "MLNScrollViewDelegate.h"
#import "UIView+MLNLayout.h"
#import "MLNLinearLayout.h"
#import "UIView+MLNKit.h"
#import "MLNLuaCore.h"
#import "MLNLayoutScrollContainerNode.h"
#import "MLNInnerScrollView.h"
#import "MLNViewConst.h"

@interface MLNScrollView()

@property (nonatomic, strong) MLNInnerScrollView *innerScrollView;

@end

@implementation MLNScrollView

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore isHorizontal:(NSNumber *)isHorizontal isLinearContenView:(NSNumber *)isLinearContenView
{
    if (self = [super initWithFrame:CGRectZero]) {
        _innerScrollView = [[MLNInnerScrollView alloc] initWithLuaCore:luaCore direction:[isHorizontal boolValue] isLinearContenView:[isLinearContenView boolValue]];
        [super lua_addSubview:_innerScrollView];
        _innerScrollView.lua_node.widthType = MLNLayoutMeasurementTypeMatchParent;
        _innerScrollView.lua_node.heightType = MLNLayoutMeasurementTypeMatchParent;
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
    MLNKitLuaAssert(NO, @"ScrollView 'contentSize' setter is deprecated");
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

- (void)setLua_scrollBeginCallback:(MLNBlock *)callback
{
    self.innerScrollView.lua_scrollBeginCallback = callback;
}

- (void)setLua_scrollingCallback:(MLNBlock *)callback
{
    self.innerScrollView.lua_scrollingCallback = callback;
}

- (void)setLua_endDraggingCallback:(MLNBlock *)callback
{
    self.innerScrollView.lua_endDraggingCallback = callback;
}

- (void)setLua_startDeceleratingCallback:(MLNBlock *)callback
{
    self.innerScrollView.lua_startDeceleratingCallback = callback;
}

- (void)setLua_scrollEndCallback:(MLNBlock *)callback
{
    self.innerScrollView.lua_scrollEndCallback = callback;
}

- (void)lua_setContentInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    [self.innerScrollView lua_setContentInset:top right:right bottom:bottom left:left];
}

- (void)lua_getContetnInset:(MLNBlock*)block
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
LUA_EXPORT_VIEW_BEGIN(MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(contentSize, "setLua_ContentSize:", "lua_contentSize", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(loadThreshold, "setLua_loadahead:", "lua_loadahead", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(contentOffset, "setLua_ContentOffset:", "lua_contentOffset", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(scrollEnabled, "setLua_ScrollEnabled:", "lua_isScrollEnabled", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(i_bounces, "setLua_Bounces:", "lua_bounces", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(showsHorizontalScrollIndicator, "setLua_showsHorizontalScrollIndicator:", "lua_showsHorizontalScrollIndicator", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(showsVerticalScrollIndicator, "setLua_showsVerticalScrollIndicator:", "lua_showsVerticalScrollIndicator", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(i_bounceHorizontal, "setLua_alwaysBounceHorizontal:", "lua_alwaysBounceHorizontal", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(i_bounceVertical, "setLua_alwaysBounceVertical:", "lua_alwaysBounceVertical", MLNScrollView)
LUA_EXPORT_VIEW_METHOD(setScrollBeginCallback, "setLua_scrollBeginCallback:",MLNScrollView)
LUA_EXPORT_VIEW_METHOD(setScrollingCallback, "setLua_scrollingCallback:",MLNScrollView)
LUA_EXPORT_VIEW_METHOD(setEndDraggingCallback, "setLua_endDraggingCallback:",MLNScrollView)
LUA_EXPORT_VIEW_METHOD(setStartDeceleratingCallback, "setLua_startDeceleratingCallback:",MLNScrollView)
LUA_EXPORT_VIEW_METHOD(setScrollEndCallback, "setLua_scrollEndCallback:",MLNScrollView)
LUA_EXPORT_VIEW_METHOD(setContentInset, "lua_setContentInset:right:bottom:left:", MLNScrollView)
LUA_EXPORT_VIEW_METHOD(getContentInset, "lua_getContetnInset:", MLNScrollView)
LUA_EXPORT_VIEW_METHOD(setScrollIndicatorInset, "lua_setScrollIndicatorInset:right:bottom:left:", MLNScrollView)
LUA_EXPORT_VIEW_METHOD(setOffsetWithAnim, "lua_setContentOffsetWithAnimation:", MLNScrollView)
LUA_EXPORT_VIEW_METHOD(setScrollEnable, "mln_setLuaScrollEnable:", MLNScrollView)
LUA_EXPORT_VIEW_END(MLNScrollView, ScrollView, YES, "MLNView", "initWithLuaCore:isHorizontal:isLinearContenView:")

@end

