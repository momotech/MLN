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
#import "MLNLayoutScrollContainerNode.h"

@interface MLNScrollView()

@property (nonatomic, strong) MLNScrollViewDelegate *lua_delegate;
@property (nonatomic, assign, getter=isLinearContenView, readonly) BOOL linearContenView;

@end

@implementation MLNScrollView

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore isHorizontal:(NSNumber *)isHorizontal isLinearContenView:(NSNumber *)isLinearContenView
{
    if (self = [self initWithLuaCore:luaCore isHorizontal:[isHorizontal boolValue]]) {
        _linearContenView = [isLinearContenView boolValue];
        self.lua_delegate = [[MLNScrollViewDelegate alloc] init];
        self.delegate = self.lua_delegate;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self createLinearLayoutIfNeed];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self recalculContentSizeIfNeed];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview && self.mln_contentView) {
        [self lua_addSubview:self.mln_contentView];
    }
}

- (void)createLinearLayoutIfNeed
{
    if (self.isLinearContenView && !self.mln_contentView) {
        self.mln_contentView = [self createLLinearLayoutWithDirection:self.mln_horizontal];
        self.mln_contentView.clipsToBounds = YES;
    }
}

- (MLNLinearLayout *)createLLinearLayoutWithDirection:(MLNScrollDirection)direction
{
    switch (direction) {
        case MLNScrollDirectionHorizontal: {
            MLNLinearLayout *linear = [[MLNLinearLayout alloc] initWithLayoutDirection:MLNLayoutDirectionHorizontal];
            linear.lua_height = MLNLayoutMeasurementTypeMatchParent;
            return linear;
        }
        default: {
            MLNLinearLayout *linear = [[MLNLinearLayout alloc] initWithLayoutDirection:MLNLayoutDirectionVertical];
            linear.lua_width = MLNLayoutMeasurementTypeMatchParent;
            return linear;
        }
    }
}

- (void)lua_setContentSize:(CGSize)contentSize
{
    MLNKitLuaAssert(NO, @"ScrollView 'contentSize' setter is deprecated");
    self.contentSize = contentSize;
    [self recalculContentSizeIfNeed];
}

- (void)recalculContentSizeIfNeed
{
    CGSize contentSize = self.contentSize;
    if (!self.mln_horizontal) {
        if (contentSize.width > self.frame.size.width && self.frame.size.width != 0) {
            contentSize.width = self.frame.size.width;
            self.contentSize = contentSize;
        }
    }
    else {
        if (contentSize.height > self.frame.size.height && self.frame.size.height != 0) {
            contentSize.height = self.frame.size.height;
            self.contentSize = contentSize;
        }
    }
}

- (void)lua_changedLayout
{
    [super lua_changedLayout];
    // 重置宽高
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
LUA_EXPORT_VIEW_PROPERTY(contentSize, "lua_setContentSize:", "contentSize", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(loadThreshold, "setLua_loadahead:", "lua_loadahead", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(contentOffset, "setContentOffset:", "contentOffset", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(scrollEnabled, "setScrollEnabled:", "isScrollEnabled", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(i_bounces, "setBounces:", "bounces", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(showsHorizontalScrollIndicator, "setShowsHorizontalScrollIndicator:", "showsHorizontalScrollIndicator", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(showsVerticalScrollIndicator, "setShowsVerticalScrollIndicator:", "showsVerticalScrollIndicator", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(i_bounceHorizontal, "setAlwaysBounceHorizontal:", "alwaysBounceHorizontal", MLNScrollView)
LUA_EXPORT_VIEW_PROPERTY(i_bounceVertical, "setAlwaysBounceVertical:", "alwaysBounceVertical", MLNScrollView)
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

