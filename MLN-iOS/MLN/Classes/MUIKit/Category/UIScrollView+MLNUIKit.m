/**
  * Created by LuaView.
  * Copyright (c) 2017, Alibaba Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */

#import "UIScrollView+MLNUIKit.h"
#import "MLNUIKitHeader.h"
#import <objc/runtime.h>
#import "UIView+MLNUIKit.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIRefreshDelegate.h"
#import "MLNUIBlock.h"
#import "MLNUIKitInstanceHandlersManager.h"

static const void *kLuaRefreshEnable = &kLuaRefreshEnable;
static const void *kLuaLoadEnable = &kLuaLoadEnable;
static const void *kLuaLoadAhead = &kLuaLoadAhead;
static const void *kLuaRefreshCallBack = &kLuaRefreshCallBack;
static const void *kLuaLoadCallBack = &kLuaLoadCallBack;
static const void *kLuaScrollWillEndDraggingCallback = &kLuaScrollWillEndDraggingCallback;

@implementation UIScrollView (MLNUIRefresh)

- (instancetype)initWithMLNUIRefreshEnable:(BOOL)refreshEnable loadEnable:(BOOL)loadEnable
{
    if (self = [self initWithFrame:CGRectZero]) {
        [self setLuaui_refreshEnable:refreshEnable];
        [self setLuaui_loadEnable:loadEnable];
    }
    return self;
}

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore isHorizontal:(BOOL)isHorizontal
{
    if (self = [self initWithMLNUILuaCore:luaCore]) {
        self.mlnui_horizontal = isHorizontal;
        self.showsHorizontalScrollIndicator = isHorizontal;
        self.showsVerticalScrollIndicator = !isHorizontal;
    }
    return self;
}

static const void *kMLNUIScrollDirection = &kMLNUIScrollDirection;
- (void)setMlnui_horizontal:(BOOL)mlnui_horizontal
{
    objc_setAssociatedObject(self, kMLNUIScrollDirection, @(mlnui_horizontal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)mlnui_horizontal
{
    return [objc_getAssociatedObject(self, kMLNUIScrollDirection) boolValue];
}

- (void)setLuaui_refreshEnable:(BOOL)luaui_refreshEnable
{
    BOOL _refreshEnable = [objc_getAssociatedObject(self, kLuaRefreshEnable) boolValue];
    if (_refreshEnable == luaui_refreshEnable) {
        return;
    }
    objc_setAssociatedObject(self, kLuaRefreshEnable, @(luaui_refreshEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
    if (luaui_refreshEnable) {
        MLNUIKitLuaAssert([delegate respondsToSelector:@selector(createHeaderForRefreshView:)], @"-[refreshDelegate createHeaderForRefreshView:] was not found!");
        [delegate createHeaderForRefreshView:self];
    } else {
        MLNUIKitLuaAssert([delegate respondsToSelector:@selector(removeHeaderForRefreshView:)], @"-[refreshDelegate removeHeaderForRefreshView:] was not found!");
        [delegate removeHeaderForRefreshView:self];
    }
}

- (BOOL)luaui_refreshEnable
{
    return [objc_getAssociatedObject(self, kLuaRefreshEnable) boolValue];
}

- (BOOL)luaui_isRefreshing
{
    id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
    MLNUIKitLuaAssert([delegate respondsToSelector:@selector(isRefreshingOfRefreshView:)], @"-[refreshDelegate isRefreshingOfRefreshView:] was not found!");
    return [delegate isRefreshingOfRefreshView:self];
}

- (void)luaui_startRefreshing
{
    id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
    MLNUIKitLuaAssert([delegate respondsToSelector:@selector(startRefreshingOfRefreshView:)], @"-[refreshDelegate startRefreshingOfRefreshView:] was not found!");
    [delegate startRefreshingOfRefreshView:self];
}

- (void)luaui_stopRefreshing
{
    id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
    MLNUIKitLuaAssert([delegate respondsToSelector:@selector(stopRefreshingOfRefreshView:)], @"-[refreshDelegate stopRefreshingOfRefreshView:] was not found!");
    [delegate stopRefreshingOfRefreshView:self];
}

- (void)luaui_startLoading {
    id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
    MLNUIKitLuaAssert([delegate respondsToSelector:@selector(startLoadingOfRefreshView:)], @"-[refreshDelegate startLoadingOfRefreshView:] was not found!");
    [delegate startLoadingOfRefreshView:self];
}

- (void)setLuaui_refreshCallback:(MLNUIBlock *)luaui_refreshCallback
{    
    objc_setAssociatedObject(self, kLuaRefreshCallBack, luaui_refreshCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)luaui_refreshCallback {
    return objc_getAssociatedObject(self, kLuaRefreshCallBack) ;
}

- (void)setLuaui_loadEnable:(BOOL)luaui_loadEnable
{
    BOOL _loadEnable = [objc_getAssociatedObject(self, kLuaLoadEnable) boolValue];;
    if (_loadEnable == luaui_loadEnable) {
        return;
    }
    objc_setAssociatedObject(self, kLuaLoadEnable, @(luaui_loadEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
    if (luaui_loadEnable) {
        MLNUIKitLuaAssert([delegate respondsToSelector:@selector(createFooterForRefreshView:)], @"-[refreshDelegate createFooterForRefreshView:] was not found!");
        [delegate createFooterForRefreshView:self];
    } else {
        MLNUIKitLuaAssert([delegate respondsToSelector:@selector(removeFooterForRefreshView:)], @"-[refreshDelegate removeFooterForRefreshView:] was not found!");
        [delegate removeFooterForRefreshView:self];
    }
}

- (BOOL)luaui_loadEnable
{
    return [objc_getAssociatedObject(self, kLuaLoadEnable) boolValue];
}

- (BOOL)luaui_isLoading
{
    id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
    MLNUIKitLuaAssert([delegate respondsToSelector:@selector(isLoadingOfRefreshView:)], @"-[refreshDelegate isLoadingOfRefreshView:] was not found!");
    return [delegate isLoadingOfRefreshView:self];
}

- (void)setLuaui_loadahead:(CGFloat)luaui_loadahead {
    MLNUIKitLuaAssert(luaui_loadahead >= 0, @"loadThreshold param must bigger or equal than 0.0!")
    if (luaui_loadahead < 0) {
        return;
    }
    objc_setAssociatedObject(self, kLuaLoadAhead, @(luaui_loadahead), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)luaui_loadahead {
    return CGFloatValueFromNumber(objc_getAssociatedObject(self, kLuaLoadAhead));
}

- (void)luaui_stopLoading
{
    id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
    MLNUIKitLuaAssert([delegate respondsToSelector:@selector(stopLoadingOfRefreshView:)], @"-[refreshDelegate stopLoadingOfRefreshView:] was not found!");
    [delegate stopLoadingOfRefreshView:self];
}

- (void)luaui_noMoreData
{
    id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
    MLNUIKitLuaAssert([delegate respondsToSelector:@selector(noMoreDataOfRefreshView:)], @"-[refreshDelegate noMoreDataOfRefreshView:] was not found!");
    [delegate noMoreDataOfRefreshView:self];
}

- (void)luaui_resetLoading
{
    id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
    MLNUIKitLuaAssert([delegate respondsToSelector:@selector(resetLoadingOfRefreshView:)], @"-[refreshDelegate resetLoadingOfRefreshView:] was not found!");
    [delegate resetLoadingOfRefreshView:self];
}

- (BOOL)luaui_isNoMoreData
{
    id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
    MLNUIKitLuaAssert([delegate respondsToSelector:@selector(isNoMoreDataOfRefreshView:)], @"-[refreshDelegate isNoMoreDataOfRefreshView:] was not found!");
    return [delegate isNoMoreDataOfRefreshView:self];
}

- (void)luaui_loadError
{
    
}

- (void)setLuaui_loadCallback:(MLNUIBlock *)luaui_loadCallback
{
    objc_setAssociatedObject(self, kLuaLoadCallBack, luaui_loadCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)luaui_loadCallback {
    return objc_getAssociatedObject(self, kLuaLoadCallBack) ;
}

- (id<MLNUIRefreshDelegate>)mlnui_getRefreshDelegate
{
    if (self.mlnui_isConvertible) {
        id<MLNUIEntityExportProtocol> ud = (id<MLNUIEntityExportProtocol>)self;
        id<MLNUIRefreshDelegate> delegate = MLNUI_KIT_INSTANCE(ud.mlnui_luaCore).instanceHandlersManager.scrollRefreshHandler;
        MLNUIKitLuaAssert(delegate, @"The refresh delegate must not be nil!");
        return delegate;
    }
    return nil;
}

static const void *kMLNUIContentvView = &kMLNUIContentvView;
- (void)setMlnui_contentView:(UIView *)mlnui_contentView
{
    objc_setAssociatedObject(self, kMLNUIContentvView, mlnui_contentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)mlnui_contentView
{
    return objc_getAssociatedObject(self, kMLNUIContentvView);
}

@end

static const void *kLuaScrollBeginCallback = &kLuaScrollBeginCallback;
static const void *kLuaScrollingCallback = &kLuaScrollingCallback;
static const void *kLuaScrollEndCallback = &kLuaScrollEndCallback;
static const void *kLuaEndDraggingCallback = &kLuaEndDraggingCallback;
static const void *kLuaStartDeceleratingCallback = &kLuaStartDeceleratingCallback;


@implementation UIScrollView (MLNUIScrolling)

- (void)setLuaui_scrollBeginCallback:(MLNUIBlock *)luaui_scrollBeginCallback
{
    objc_setAssociatedObject(self, kLuaScrollBeginCallback, luaui_scrollBeginCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)luaui_scrollBeginCallback
{
    return objc_getAssociatedObject(self, kLuaScrollBeginCallback);
}

- (void)setLuaui_scrollingCallback:(MLNUIBlock *)luaui_scrollingCallback
{
    objc_setAssociatedObject(self, kLuaScrollingCallback, luaui_scrollingCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)luaui_scrollingCallback
{
    return objc_getAssociatedObject(self, kLuaScrollingCallback);
}

- (void)setLuaui_scrollEndCallback:(MLNUIBlock *)luaui_scrollEndCallback
{
    objc_setAssociatedObject(self, kLuaScrollEndCallback, luaui_scrollEndCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)luaui_scrollEndCallback
{
    return objc_getAssociatedObject(self, kLuaScrollEndCallback);
}

- (void)setLuaui_startDeceleratingCallback:(MLNUIBlock *)luaui_startDeceleratingCallback
{
    objc_setAssociatedObject(self, kLuaStartDeceleratingCallback, luaui_startDeceleratingCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)luaui_startDeceleratingCallback
{
    return objc_getAssociatedObject(self, kLuaStartDeceleratingCallback);
}

- (void)setLuaui_scrollWillEndDraggingCallback:(MLNUIBlock *)luaui_scrollWillEndDraggingCallback {
    objc_setAssociatedObject(self, kLuaScrollWillEndDraggingCallback, luaui_scrollWillEndDraggingCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)luaui_scrollWillEndDraggingCallback {
    return objc_getAssociatedObject(self, kLuaScrollWillEndDraggingCallback);
}

- (void)setLuaui_endDraggingCallback:(MLNUIBlock *)luaui_endDraggingCallback
{
    objc_setAssociatedObject(self, kLuaEndDraggingCallback, luaui_endDraggingCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)luaui_endDraggingCallback
{
    return objc_getAssociatedObject(self, kLuaEndDraggingCallback);
}

- (void)luaui_setScrollIndicatorInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom  left:(CGFloat)left
{
    MLNUIKitLuaAssert(NO, @"ScrollView:setScrollIndicatorInset method is deprecated");
    self.scrollIndicatorInsets = UIEdgeInsetsMake(top, left, bottom, right);
}

- (void)luaui_setContentInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    self.contentInset = UIEdgeInsetsMake(top, left, bottom, right);
    self.scrollIndicatorInsets = UIEdgeInsetsMake(top, left, bottom, right);
}

- (void)luaui_getContetnInset:(MLNUIBlock*)block
{
    if (block) {
        [block addFloatArgument:self.contentInset.top];
        [block addFloatArgument:self.contentInset.right];
        [block addFloatArgument:self.contentInset.bottom];
        [block addFloatArgument:self.contentInset.left];
        [block callIfCan];
    }
}

- (void)luaui_setContentOffsetWithAnimation:(CGPoint)point
{
    if(self.mlnui_horizontal) {
        point.x = point.x < 0 ? 0 : point.x;
        [self setContentOffset:CGPointMake(point.x, 0) animated:YES];
    } else {
        point.y = point.y < 0 ? 0 : point.y;
        [self setContentOffset:CGPointMake(0, point.y) animated:YES];
    }
}

- (void)luaui_setContentOffset:(CGPoint)point
{
    if(self.mlnui_horizontal) {
        point.x = point.x < 0 ? 0 : point.x;
        [self setContentOffset:CGPointMake(point.x, 0) animated:NO];
    } else {
        point.y = point.y < 0 ? 0 : point.y;
        [self setContentOffset:CGPointMake(0, point.y) animated:NO];
    }
}

- (CGPoint)luaui_contentOffset
{
    return self.contentOffset;
}

- (void)luaui_setPagerContentOffset:(CGFloat)x y:(CGFloat)y {
    if(self.mlnui_horizontal) {
        x = x < 0 ? 0 : x;
        [self setContentOffset:CGPointMake(x, 0) animated:NO];
    } else {
        y = y < 0 ? 0 : y;
        [self setContentOffset:CGPointMake(0, y) animated:NO];
    }
}

//@override
- (void)luaui_addSubview:(UIView *)view
{
    if (self.mlnui_contentView && self.mlnui_contentView != view) {
        [self.mlnui_contentView luaui_addSubview:view];
    } else {
        [super luaui_addSubview:view];
    }
}

- (void)luaui_removeAllSubViews {
    if (self.mlnui_contentView) {
        [self.mlnui_contentView luaui_removeAllSubViews];
    } else {
        [super luaui_removeAllSubViews];
    }
}

- (void)mlnui_setLuaScrollEnable:(BOOL)enable
{
    self.scrollEnabled = enable;
}

- (void)setLuaui_disallowFling:(BOOL)disallowFling {
    objc_setAssociatedObject(self, @selector(luaui_disallowFling), @(disallowFling), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)luaui_disallowFling {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end


