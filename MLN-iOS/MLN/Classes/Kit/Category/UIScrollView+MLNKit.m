/**
  * Created by LuaView.
  * Copyright (c) 2017, Alibaba Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */

#import "UIScrollView+MLNKit.h"
#import "MLNKitHeader.h"
#import <objc/runtime.h>
#import "UIView+MLNKit.h"
#import "UIView+MLNLayout.h"
#import "MLNRefreshDelegate.h"
#import "MLNBlock.h"
#import "MLNKitInstanceHandlersManager.h"

static const void *kLuaRefreshEnable = &kLuaRefreshEnable;
static const void *kLuaLoadEnable = &kLuaLoadEnable;
static const void *kLuaLoadAhead = &kLuaLoadAhead;
static const void *kLuaRefreshCallBack = &kLuaRefreshCallBack;
static const void *kLuaLoadCallBack = &kLuaLoadCallBack;

@implementation UIScrollView (MLNRefresh)

- (instancetype)initWithRefreshEnable:(BOOL)refreshEnable loadEnable:(BOOL)loadEnable
{
    if (self = [self initWithFrame:CGRectZero]) {
        [self setLua_refreshEnable:refreshEnable];
        [self setLua_loadEnable:loadEnable];
    }
    return self;
}

- (instancetype)initWithLuaCore:(MLNLuaCore *)luaCore isHorizontal:(BOOL)isHorizontal
{
    if (self = [self initWithLuaCore:luaCore]) {
        self.mln_horizontal = isHorizontal;
        self.showsHorizontalScrollIndicator = isHorizontal;
        self.showsVerticalScrollIndicator = !isHorizontal;
    }
    return self;
}

static const void *kMLNScrollDirection = &kMLNScrollDirection;
- (void)setMln_horizontal:(BOOL)mln_horizontal
{
    objc_setAssociatedObject(self, kMLNScrollDirection, @(mln_horizontal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)mln_horizontal
{
    return [objc_getAssociatedObject(self, kMLNScrollDirection) boolValue];
}

- (void)setLua_refreshEnable:(BOOL)lua_refreshEnable
{
    BOOL _refreshEnable = [objc_getAssociatedObject(self, kLuaRefreshEnable) boolValue];
    if (_refreshEnable == lua_refreshEnable) {
        return;
    }
    objc_setAssociatedObject(self, kLuaRefreshEnable, @(lua_refreshEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
    if (lua_refreshEnable) {
        MLNKitLuaAssert([delegate respondsToSelector:@selector(createHeaderForRefreshView:)], @"-[refreshDelegate createHeaderForRefreshView:] was not found!");
        [delegate createHeaderForRefreshView:self];
    } else {
        MLNKitLuaAssert([delegate respondsToSelector:@selector(removeHeaderForRefreshView:)], @"-[refreshDelegate removeHeaderForRefreshView:] was not found!");
        [delegate removeHeaderForRefreshView:self];
    }
}

- (BOOL)lua_refreshEnable
{
    return [objc_getAssociatedObject(self, kLuaRefreshEnable) boolValue];
}

- (BOOL)lua_isRefreshing
{
    id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
    MLNKitLuaAssert([delegate respondsToSelector:@selector(isRefreshingOfRefreshView:)], @"-[refreshDelegate isRefreshingOfRefreshView:] was not found!");
    return [delegate isRefreshingOfRefreshView:self];
}

- (void)lua_startRefreshing
{
    id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
    MLNKitLuaAssert([delegate respondsToSelector:@selector(startRefreshingOfRefreshView:)], @"-[refreshDelegate startRefreshingOfRefreshView:] was not found!");
    [delegate startRefreshingOfRefreshView:self];
}

- (void)lua_stopRefreshing
{
    id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
    MLNKitLuaAssert([delegate respondsToSelector:@selector(stopRefreshingOfRefreshView:)], @"-[refreshDelegate stopRefreshingOfRefreshView:] was not found!");
    [delegate stopRefreshingOfRefreshView:self];
}

- (void)lua_startLoading {
    id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
    MLNKitLuaAssert([delegate respondsToSelector:@selector(startLoadingOfRefreshView:)], @"-[refreshDelegate startLoadingOfRefreshView:] was not found!");
    [delegate startLoadingOfRefreshView:self];
}

- (void)setLua_refreshCallback:(MLNBlock *)lua_refreshCallback
{    
    objc_setAssociatedObject(self, kLuaRefreshCallBack, lua_refreshCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNBlock *)lua_refreshCallback {
    return objc_getAssociatedObject(self, kLuaRefreshCallBack) ;
}

- (void)setLua_loadEnable:(BOOL)lua_loadEnable
{
    BOOL _loadEnable = [objc_getAssociatedObject(self, kLuaLoadEnable) boolValue];;
    if (_loadEnable == lua_loadEnable) {
        return;
    }
    objc_setAssociatedObject(self, kLuaLoadEnable, @(lua_loadEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
    if (lua_loadEnable) {
        MLNKitLuaAssert([delegate respondsToSelector:@selector(createFooterForRefreshView:)], @"-[refreshDelegate createFooterForRefreshView:] was not found!");
        [delegate createFooterForRefreshView:self];
    } else {
        MLNKitLuaAssert([delegate respondsToSelector:@selector(removeFooterForRefreshView:)], @"-[refreshDelegate removeFooterForRefreshView:] was not found!");
        [delegate removeFooterForRefreshView:self];
    }
}

- (BOOL)lua_loadEnable
{
    return [objc_getAssociatedObject(self, kLuaLoadEnable) boolValue];
}

- (BOOL)lua_isLoading
{
    id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
    MLNKitLuaAssert([delegate respondsToSelector:@selector(isLoadingOfRefreshView:)], @"-[refreshDelegate isLoadingOfRefreshView:] was not found!");
    return [delegate isLoadingOfRefreshView:self];
}

- (void)setLua_loadahead:(CGFloat)lua_loadahead {
    MLNKitLuaAssert(lua_loadahead >= 0, @"loadThreshold param must bigger or equal than 0.0!")
    if (lua_loadahead < 0) {
        return;
    }
    objc_setAssociatedObject(self, kLuaLoadAhead, @(lua_loadahead), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)lua_loadahead {
    return CGFloatValueFromNumber(objc_getAssociatedObject(self, kLuaLoadAhead));
}

- (void)lua_stopLoading
{
    id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
    MLNKitLuaAssert([delegate respondsToSelector:@selector(stopLoadingOfRefreshView:)], @"-[refreshDelegate stopLoadingOfRefreshView:] was not found!");
    [delegate stopLoadingOfRefreshView:self];
}

- (void)lua_noMoreData
{
    id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
    MLNKitLuaAssert([delegate respondsToSelector:@selector(noMoreDataOfRefreshView:)], @"-[refreshDelegate noMoreDataOfRefreshView:] was not found!");
    [delegate noMoreDataOfRefreshView:self];
}

- (void)lua_resetLoading
{
    id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
    MLNKitLuaAssert([delegate respondsToSelector:@selector(resetLoadingOfRefreshView:)], @"-[refreshDelegate resetLoadingOfRefreshView:] was not found!");
    [delegate resetLoadingOfRefreshView:self];
}

- (BOOL)lua_isNoMoreData
{
    id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
    MLNKitLuaAssert([delegate respondsToSelector:@selector(isNoMoreDataOfRefreshView:)], @"-[refreshDelegate isNoMoreDataOfRefreshView:] was not found!");
    return [delegate isNoMoreDataOfRefreshView:self];
}

- (void)lua_loadError
{
    
}

- (void)setLua_loadCallback:(MLNBlock *)lua_loadCallback
{
    objc_setAssociatedObject(self, kLuaLoadCallBack, lua_loadCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNBlock *)lua_loadCallback {
    return objc_getAssociatedObject(self, kLuaLoadCallBack) ;
}

- (id<MLNRefreshDelegate>)getRefreshDelegate
{
    if (self.mln_isConvertible) {
        id<MLNEntityExportProtocol> ud = (id<MLNEntityExportProtocol>)self;
        id<MLNRefreshDelegate> delegate = MLN_KIT_INSTANCE(ud.mln_luaCore).instanceHandlersManager.scrollRefreshHandler;
        MLNKitLuaAssert(delegate, @"The refresh delegate must not be nil!");
        return delegate;
    }
    return nil;
}

static const void *kMLNContentvView = &kMLNContentvView;
- (void)setMln_contentView:(UIView *)mln_contentView
{
    objc_setAssociatedObject(self, kMLNContentvView, mln_contentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)mln_contentView
{
    return objc_getAssociatedObject(self, kMLNContentvView);
}

@end

static const void *kLuaScrollBeginCallback = &kLuaScrollBeginCallback;
static const void *kLuaScrollingCallback = &kLuaScrollingCallback;
static const void *kLuaScrollEndCallback = &kLuaScrollEndCallback;
static const void *kLuaEndDraggingCallback = &kLuaEndDraggingCallback;
static const void *kLuaStartDeceleratingCallback = &kLuaStartDeceleratingCallback;


@implementation UIScrollView (MLNScrolling)

- (void)setLua_scrollBeginCallback:(MLNBlock *)lua_scrollBeginCallback
{
    objc_setAssociatedObject(self, kLuaScrollBeginCallback, lua_scrollBeginCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNBlock *)lua_scrollBeginCallback
{
    return objc_getAssociatedObject(self, kLuaScrollBeginCallback);
}

- (void)setLua_scrollingCallback:(MLNBlock *)lua_scrollingCallback
{
    objc_setAssociatedObject(self, kLuaScrollingCallback, lua_scrollingCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNBlock *)lua_scrollingCallback
{
    return objc_getAssociatedObject(self, kLuaScrollingCallback);
}

- (void)setLua_scrollEndCallback:(MLNBlock *)lua_scrollEndCallback
{
    objc_setAssociatedObject(self, kLuaScrollEndCallback, lua_scrollEndCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNBlock *)lua_scrollEndCallback
{
    return objc_getAssociatedObject(self, kLuaScrollEndCallback);
}

- (void)setLua_startDeceleratingCallback:(MLNBlock *)lua_startDeceleratingCallback
{
    objc_setAssociatedObject(self, kLuaStartDeceleratingCallback, lua_startDeceleratingCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNBlock *)lua_startDeceleratingCallback
{
    return objc_getAssociatedObject(self, kLuaStartDeceleratingCallback);
}

- (void)setLua_endDraggingCallback:(MLNBlock *)lua_endDraggingCallback
{
    objc_setAssociatedObject(self, kLuaEndDraggingCallback, lua_endDraggingCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNBlock *)lua_endDraggingCallback
{
    return objc_getAssociatedObject(self, kLuaEndDraggingCallback);
}

- (void)lua_setScrollIndicatorInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom  left:(CGFloat)left
{
    MLNKitLuaAssert(NO, @"ScrollView:setScrollIndicatorInset method is deprecated");
    self.scrollIndicatorInsets = UIEdgeInsetsMake(top, left, bottom, right);
}

- (void)lua_setContentInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    self.contentInset = UIEdgeInsetsMake(top, left, bottom, right);
    self.scrollIndicatorInsets = UIEdgeInsetsMake(top, left, bottom, right);
}

- (void)lua_getContetnInset:(MLNBlock*)block
{
    if (block) {
        [block addFloatArgument:self.contentInset.top];
        [block addFloatArgument:self.contentInset.right];
        [block addFloatArgument:self.contentInset.bottom];
        [block addFloatArgument:self.contentInset.left];
        [block callIfCan];
    }
}

- (void)lua_setContentOffsetWithAnimation:(CGPoint)point
{
    if(self.mln_horizontal) {
        point.x = point.x < 0 ? 0 : point.x;
        [self setContentOffset:CGPointMake(point.x, 0) animated:YES];
    } else {
        point.y = point.y < 0 ? 0 : point.y;
        [self setContentOffset:CGPointMake(0, point.y) animated:YES];
    }
}

- (void)lua_setContentOffset:(CGPoint)point
{
    if(self.mln_horizontal) {
        point.x = point.x < 0 ? 0 : point.x;
        [self setContentOffset:CGPointMake(point.x, 0)];
    } else {
        point.y = point.y < 0 ? 0 : point.y;
        [self setContentOffset:CGPointMake(0, point.y)];
    }
}

- (CGPoint)lua_contentOffset
{
    return self.contentOffset;
}

//@override
- (void)lua_addSubview:(UIView *)view
{
    if (self.mln_contentView && self.mln_contentView != view) {
        [self.mln_contentView lua_addSubview:view];
    } else {
        [super lua_addSubview:view];
    }
}

- (void)mln_setLuaScrollEnable:(BOOL)enable
{
    self.scrollEnabled = enable;
}

@end


