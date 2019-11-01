//
//  MLNScrollCallbackView.m
//
//
//  Created by MoMo on 2019/6/19.
//

#import "MLNScrollCallbackView.h"
#import "UIView+MLNLayout.h"
#import "MLNKitHeader.h"
#import "MLNViewExporterMacro.h"
#import "UIScrollView+MLNKit.h"
#import "MLNKitInstanceHandlersManager.h"
#import "MLNBlock.h"

#define SCROLLVIEW_DO(...)\
if ([self.lua_contentView isKindOfClass:[UIScrollView class]]) {\
UIScrollView *scrollView = (UIScrollView *)self.lua_contentView;\
__VA_ARGS__;\
}

@interface MLNScrollCallbackView ()

@property(nonatomic, weak) MLNLuaCore *mln_luaCore;

@end

@implementation MLNScrollCallbackView

- (void)setLua_openReuseCell:(BOOL)openRuseCell
{
    MLNKitLuaAssert(NO, @"The setter of 'openReuseCell' method is deprecated!");
}

- (BOOL)lua_openReuseCell
{
    MLNKitLuaAssert(NO, @"The getter of 'openReuseCell' method is deprecated!");
    return NO;
}

- (void)setLua_minWidth:(CGFloat)lua_minWidth
{
    MLNKitLuaAssert(NO, @"Not support 'setMinWidth' method!");
}

- (void)setLua_maxWidth:(CGFloat)lua_maxWidth
{
    MLNKitLuaAssert(NO, @"Not support 'setMaxWidth' method!");
}

- (void)setLua_minHeight:(CGFloat)lua_minHeight
{
    MLNKitLuaAssert(NO, @"Not support 'setMinHeight' method!");
}

- (void)setLua_maxHieght:(CGFloat)lua_maxHieght
{
    MLNKitLuaAssert(NO, @"Not support 'setMaxHeight' method!");
}

#pragma mark - ScrollView Callback
- (void)mln_setLuaScrollEnable:(BOOL)enable
{
    SCROLLVIEW_DO(scrollView.scrollEnabled = enable;)
}

- (void)setLua_refreshEnable:(BOOL)lua_refreshEnable
{
    SCROLLVIEW_DO(if (scrollView.lua_refreshEnable == lua_refreshEnable) {
        return;
    }
                  scrollView.lua_refreshEnable = lua_refreshEnable;
                  id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
                  if (lua_refreshEnable) {
                      MLNKitLuaAssert([delegate respondsToSelector:@selector(createHeaderForRefreshView:)], @"-[refreshDelegate createHeaderForRefreshView:] was not found!");
                      [delegate createHeaderForRefreshView:scrollView];
                  } else {
                      MLNKitLuaAssert([delegate respondsToSelector:@selector(removeHeaderForRefreshView:)], @"-[refreshDelegate removeHeaderForRefreshView:] was not found!");
                      [delegate removeHeaderForRefreshView:scrollView];
                  })
}

- (BOOL)lua_refreshEnable
{
    SCROLLVIEW_DO(return scrollView.lua_refreshEnable;)
    return NO;
}

- (BOOL)lua_isRefreshing
{
    SCROLLVIEW_DO(id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
                  MLNKitLuaAssert([delegate respondsToSelector:@selector(isRefreshingOfRefreshView:)], @"-[refreshDelegate isRefreshingOfRefreshView:] was not found!");
                  return [delegate isRefreshingOfRefreshView:scrollView];
                  )
    return NO;
}

- (void)lua_startRefreshing
{
    SCROLLVIEW_DO(id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
                  MLNKitLuaAssert([delegate respondsToSelector:@selector(startRefreshingOfRefreshView:)], @"-[refreshDelegate startRefreshingOfRefreshView:] was not found!");
                  [delegate startRefreshingOfRefreshView:scrollView];
                  )
}

- (void)lua_stopRefreshing
{
    SCROLLVIEW_DO(id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
                  MLNKitLuaAssert([delegate respondsToSelector:@selector(stopRefreshingOfRefreshView:)], @"-[refreshDelegate stopRefreshingOfRefreshView:] was not found!");
                  [delegate stopRefreshingOfRefreshView:scrollView];
                  )
}

- (void)lua_startLoading {
    SCROLLVIEW_DO(id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
                  MLNKitLuaAssert([delegate respondsToSelector:@selector(startLoadingOfRefreshView:)], @"-[refreshDelegate startLoadingOfRefreshView:] was not found!");
                  [delegate startLoadingOfRefreshView:scrollView];
                  )
}

- (void)setLua_refreshCallback:(MLNBlock *)lua_refreshCallback
{
    MLNCheckTypeAndNilValue(lua_refreshCallback, @"callback", MLNBlock);
    SCROLLVIEW_DO(scrollView.lua_refreshCallback = lua_refreshCallback;)
}

- (MLNBlock *)lua_refreshCallback {
    SCROLLVIEW_DO(return scrollView.lua_refreshCallback;)
    return nil;
}

- (void)setLua_loadEnable:(BOOL)lua_loadEnable
{
    SCROLLVIEW_DO(if (scrollView.lua_loadEnable == lua_loadEnable) {
        return;
    }
                  scrollView.lua_loadEnable = lua_loadEnable;
                  id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
                  if (lua_loadEnable) {
                      MLNKitLuaAssert([delegate respondsToSelector:@selector(createFooterForRefreshView:)], @"-[refreshDelegate createFooterForRefreshView:] was not found!");
                      [delegate createFooterForRefreshView:scrollView];
                  } else {
                      MLNKitLuaAssert([delegate respondsToSelector:@selector(removeFooterForRefreshView:)], @"-[refreshDelegate removeFooterForRefreshView:] was not found!");
                      [delegate removeFooterForRefreshView:scrollView];
                  })
}

- (BOOL)lua_loadEnable
{
    SCROLLVIEW_DO(return scrollView.lua_loadEnable;)
    return NO;
}

- (BOOL)lua_isLoading
{
    SCROLLVIEW_DO(id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
                  MLNKitLuaAssert([delegate respondsToSelector:@selector(isLoadingOfRefreshView:)], @"-[refreshDelegate isLoadingOfRefreshView:] was not found!");
                  return [delegate isLoadingOfRefreshView:scrollView];
                  )
    return NO;
}

- (void)setLua_loadahead:(CGFloat)lua_loadahead {
    SCROLLVIEW_DO(MLNKitLuaAssert(lua_loadahead >= 0, @"loadThreshold param must bigger or equal than 0.0!")
                  if (lua_loadahead < 0) {
                      return;
                  }
                  scrollView.lua_loadahead = lua_loadahead;
                  )
}

- (CGFloat)lua_loadahead {
    SCROLLVIEW_DO(return scrollView.lua_loadahead)
    return 0.1;
}

- (void)lua_stopLoading
{
    SCROLLVIEW_DO(id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
                  MLNKitLuaAssert([delegate respondsToSelector:@selector(stopLoadingOfRefreshView:)], @"-[refreshDelegate stopLoadingOfRefreshView:] was not found!");
                  [delegate stopLoadingOfRefreshView:scrollView];)
}

- (void)lua_noMoreData
{
    SCROLLVIEW_DO(id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
                  MLNKitLuaAssert([delegate respondsToSelector:@selector(noMoreDataOfRefreshView:)], @"-[refreshDelegate noMoreDataOfRefreshView:] was not found!");
                  [delegate noMoreDataOfRefreshView:scrollView];)
}

- (void)lua_resetLoading
{
    SCROLLVIEW_DO(id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
                  MLNKitLuaAssert([delegate respondsToSelector:@selector(resetLoadingOfRefreshView:)], @"-[refreshDelegate resetLoadingOfRefreshView:] was not found!");
                  [delegate resetLoadingOfRefreshView:scrollView];
                  )
}

- (BOOL)lua_isNoMoreData
{
    SCROLLVIEW_DO(id<MLNRefreshDelegate> delegate = [self getRefreshDelegate];
                  MLNKitLuaAssert([delegate respondsToSelector:@selector(isNoMoreDataOfRefreshView:)], @"-[refreshDelegate isNoMoreDataOfRefreshView:] was not found!");
                  return [delegate isNoMoreDataOfRefreshView:scrollView];
                  )
    return NO;
}

- (void)lua_loadError
{
    // @note Android需要用到此方法，iOS空实现
}

- (void)setLua_loadCallback:(MLNBlock *)lua_loadCallback
{
    MLNCheckTypeAndNilValue(lua_loadCallback, @"function", MLNBlock);
    SCROLLVIEW_DO(scrollView.lua_loadCallback = lua_loadCallback;)
}

- (MLNBlock *)lua_loadCallback {
    SCROLLVIEW_DO(return scrollView.lua_loadCallback;)
    return nil;
}

- (id<MLNRefreshDelegate>)getRefreshDelegate
{
    return MLN_KIT_INSTANCE(self.mln_luaCore).instanceHandlersManager.scrollRefreshHandler;
}

- (void)setLua_scrollBeginCallback:(MLNBlock *)lua_scrollBeginCallback
{
    SCROLLVIEW_DO(scrollView.lua_scrollBeginCallback = lua_scrollBeginCallback;)
}

- (MLNBlock *)lua_scrollBeginCallback
{
    SCROLLVIEW_DO(return scrollView.lua_scrollBeginCallback;)
    return nil;
}

- (void)setLua_scrollingCallback:(MLNBlock *)lua_scrollingCallback
{
    MLNCheckTypeAndNilValue(lua_scrollingCallback, @"function", MLNBlock);
    SCROLLVIEW_DO(scrollView.lua_scrollingCallback = lua_scrollingCallback;)
}

- (MLNBlock *)lua_scrollingCallback
{
    SCROLLVIEW_DO(return scrollView.lua_scrollingCallback;)
    return nil;
}

- (void)setLua_scrollEndCallback:(MLNBlock *)lua_scrollEndCallback
{
    MLNCheckTypeAndNilValue(lua_scrollEndCallback, @"function", MLNBlock);
    SCROLLVIEW_DO(scrollView.lua_scrollEndCallback = lua_scrollEndCallback;)
}

- (MLNBlock *)lua_scrollEndCallback
{
    SCROLLVIEW_DO(return scrollView.lua_scrollEndCallback);
    return nil;
}

- (void)setLua_startDeceleratingCallback:(MLNBlock *)lua_startDeceleratingCallback
{
    MLNCheckTypeAndNilValue(lua_startDeceleratingCallback, @"function", MLNBlock);
    SCROLLVIEW_DO(scrollView.lua_startDeceleratingCallback = lua_startDeceleratingCallback;)
}

- (MLNBlock *)lua_startDeceleratingCallback
{
    SCROLLVIEW_DO(return scrollView.lua_startDeceleratingCallback;)
    return nil;
}

- (void)setLua_endDraggingCallback:(MLNBlock *)lua_endDraggingCallback
{
    MLNCheckTypeAndNilValue(lua_endDraggingCallback, @"function", MLNBlock);
    SCROLLVIEW_DO(scrollView.lua_endDraggingCallback = lua_endDraggingCallback;)
}

- (MLNBlock *)lua_endDraggingCallback
{
    SCROLLVIEW_DO(return scrollView.lua_endDraggingCallback;)
    return nil;
}

- (void)lua_setContentInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    SCROLLVIEW_DO(scrollView.contentInset = UIEdgeInsetsMake(top, left, bottom, right);
                  if (UIEdgeInsetsEqualToEdgeInsets(scrollView.scrollIndicatorInsets, UIEdgeInsetsZero)) {
                      scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(top, left, bottom, right);
                  })
}

- (void)lua_getContetnInset:(MLNBlock*)block
{
    SCROLLVIEW_DO(if(block) {
        [block addFloatArgument:scrollView.contentInset.top];
        [block addFloatArgument:scrollView.contentInset.right];
        [block addFloatArgument:scrollView.contentInset.bottom];
        [block addFloatArgument:scrollView.contentInset.left];
        [block callIfCan];
    })
}

#pragma mark - Privious scrollView  method

- (void)lua_setContentSize:(CGSize)contentSize
{
    MLNKitLuaAssert(NO, @"The setter of 'contentSize' method is deprecated!");
    SCROLLVIEW_DO(scrollView.contentSize = contentSize;
                  [self recalculContentSizeIfNeed];)
}

- (void)recalculContentSizeIfNeed
{
    SCROLLVIEW_DO(CGSize contentSize = scrollView.contentSize;
                  if (!scrollView.mln_horizontal) {
                      if (contentSize.width > scrollView.frame.size.width && scrollView.frame.size.width != 0) {
                          contentSize.width = scrollView.frame.size.width;
                          scrollView.contentSize = contentSize;
                      }
                  }
                  else {
                      if (contentSize.height > scrollView.frame.size.height && scrollView.frame.size.height != 0) {
                          contentSize.height = scrollView.frame.size.height;
                          scrollView.contentSize = contentSize;
                      }
                  })
}

- (CGSize)lua_contentSize
{
    MLNKitLuaAssert(NO, @"The 'contentSize' method is deprecated!");
    SCROLLVIEW_DO(return scrollView.contentSize;)
    return CGSizeZero;
}

- (void)lua_setScrollEnabled:(BOOL)enable
{
    MLNKitLuaAssert(NO, @"The setter of 'scrollEnabled' method is deprecated!");
    SCROLLVIEW_DO(scrollView.scrollEnabled = enable;)
}

- (BOOL)lua_scrollEnabled
{
    MLNKitLuaAssert(NO, @"The getter of 'scrollEnabled' method is deprecated!");
    SCROLLVIEW_DO(return scrollView.scrollEnabled;)
    return NO;
}



#pragma mark - iOS私有方法
- (CGPoint)lua_contentOffset
{
    SCROLLVIEW_DO(return scrollView.contentOffset;)
    return CGPointZero;
}

- (void)lua_setContentOffset:(CGPoint)point
{
    SCROLLVIEW_DO(if(scrollView.mln_horizontal) {
        point.x = point.x < 0 ? 0 : point.x;
        [scrollView setContentOffset:CGPointMake(point.x, 0)];
    } else {
        point.y = point.y < 0 ? 0 : point.y;
        [scrollView setContentOffset:CGPointMake(0, point.y)];
    })
}

- (void)lua_setBounces:(BOOL)bouces
{
    SCROLLVIEW_DO(scrollView.bounces = bouces;)
}

- (BOOL)lua_bounces
{
    SCROLLVIEW_DO(return scrollView.bounces);
    return NO;
}

- (void)lua_setAlwaysBounceHorizontal:(BOOL)bouces
{
    SCROLLVIEW_DO(scrollView.alwaysBounceHorizontal = bouces;)
}

- (BOOL)lua_alwaysBounceHorizontal
{
    SCROLLVIEW_DO(return scrollView.alwaysBounceHorizontal);
    return NO;
}

- (void)lua_setAlwaysBounceVertical:(BOOL)bouces
{
    SCROLLVIEW_DO(scrollView.alwaysBounceVertical = bouces;)
}

- (BOOL)lua_alwaysBounceVertical
{
    SCROLLVIEW_DO(return scrollView.alwaysBounceVertical);
    return NO;
}

- (void)lua_setScrollIndicatorInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom  left:(CGFloat)left
{
    SCROLLVIEW_DO(scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(top, left, bottom, right);)
}

- (void)lua_setContentOffsetWithAnimation:(CGPoint)point
{
    SCROLLVIEW_DO(if(scrollView.mln_horizontal) {
        point.x = point.x < 0 ? 0 : point.x;
        [scrollView setContentOffset:CGPointMake(point.x, 0) animated:YES];
    } else {
        point.y = point.y < 0 ? 0 : point.y;
        [scrollView setContentOffset:CGPointMake(0, point.y) animated:YES];
    })
}

@end
