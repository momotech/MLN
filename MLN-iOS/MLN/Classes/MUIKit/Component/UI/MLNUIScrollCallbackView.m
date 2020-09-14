//
//  MLNUIScrollCallbackView.m
//
//
//  Created by MoMo on 2019/6/19.
//

#import "MLNUIScrollCallbackView.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "UIScrollView+MLNUIKit.h"
#import "MLNUIKitInstanceHandlersManager.h"
#import "MLNUIBlock.h"

#define SCROLLVIEW_DO(...)\
if ([self.mlnui_contentView isKindOfClass:[UIScrollView class]]) {\
UIScrollView *scrollView = (UIScrollView *)self.mlnui_contentView;\
__VA_ARGS__;\
}

@interface MLNUIScrollCallbackView ()

@property(nonatomic, weak) MLNUILuaCore *mlnui_luaCore;

@end

@implementation MLNUIScrollCallbackView

- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore refreshEnable:(NSNumber *)refreshEnable loadEnable:(NSNumber *)loadEnable
{
    if (self = [super initWithMLNUILuaCore:luaCore]) {
        self.backgroundColor = [UIColor clearColor];
        [(UIScrollView *)self.mlnui_contentView setLuaui_refreshEnable:[refreshEnable boolValue]];
        [(UIScrollView *)self.mlnui_contentView setLuaui_loadEnable:[loadEnable boolValue]];
    }
    return self;
}

- (void)setLuaui_openReuseCell:(BOOL)openRuseCell
{
    MLNUIKitLuaAssert(NO, @"The setter of 'openReuseCell' method is deprecated!");
}

- (BOOL)luaui_openReuseCell
{
    MLNUIKitLuaAssert(NO, @"The getter of 'openReuseCell' method is deprecated!");
    return NO;
}

- (void)setLuaui_minWidth:(CGFloat)luaui_minWidth
{
    MLNUIKitLuaAssert(NO, @"Not support 'setMinWidth' method!");
}

- (void)setLuaui_maxWidth:(CGFloat)luaui_maxWidth
{
    MLNUIKitLuaAssert(NO, @"Not support 'setMaxWidth' method!");
}

- (void)setLuaui_minHeight:(CGFloat)luaui_minHeight
{
    MLNUIKitLuaAssert(NO, @"Not support 'setMinHeight' method!");
}

- (void)setLuaui_maxHieght:(CGFloat)luaui_maxHieght
{
    MLNUIKitLuaAssert(NO, @"Not support 'setMaxHeight' method!");
}

#pragma mark - ScrollView Callback
- (void)mlnui_setLuaScrollEnable:(BOOL)enable
{
    SCROLLVIEW_DO(scrollView.scrollEnabled = enable;)
}

- (void)setLuaui_refreshEnable:(BOOL)luaui_refreshEnable
{
    SCROLLVIEW_DO(if (scrollView.luaui_refreshEnable == luaui_refreshEnable) {
        return;
    }
                  scrollView.luaui_refreshEnable = luaui_refreshEnable;
                  id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
                  if (luaui_refreshEnable) {
                      MLNUIKitLuaAssert([delegate respondsToSelector:@selector(createHeaderForRefreshView:)], @"-[refreshDelegate createHeaderForRefreshView:] was not found!");
                      [delegate createHeaderForRefreshView:scrollView];
                  } else {
                      MLNUIKitLuaAssert([delegate respondsToSelector:@selector(removeHeaderForRefreshView:)], @"-[refreshDelegate removeHeaderForRefreshView:] was not found!");
                      [delegate removeHeaderForRefreshView:scrollView];
                  })
}

- (BOOL)luaui_refreshEnable
{
    SCROLLVIEW_DO(return scrollView.luaui_refreshEnable;)
    return NO;
}

- (BOOL)luaui_isRefreshing
{
    SCROLLVIEW_DO(id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
                  MLNUIKitLuaAssert([delegate respondsToSelector:@selector(isRefreshingOfRefreshView:)], @"-[refreshDelegate isRefreshingOfRefreshView:] was not found!");
                  return [delegate isRefreshingOfRefreshView:scrollView];
                  )
    return NO;
}

- (void)luaui_startRefreshing
{
    SCROLLVIEW_DO(id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
                  MLNUIKitLuaAssert([delegate respondsToSelector:@selector(startRefreshingOfRefreshView:)], @"-[refreshDelegate startRefreshingOfRefreshView:] was not found!");
                  [delegate startRefreshingOfRefreshView:scrollView];
                  )
}

- (void)luaui_stopRefreshing
{
    SCROLLVIEW_DO(id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
                  MLNUIKitLuaAssert([delegate respondsToSelector:@selector(stopRefreshingOfRefreshView:)], @"-[refreshDelegate stopRefreshingOfRefreshView:] was not found!");
                  [delegate stopRefreshingOfRefreshView:scrollView];
                  )
}

- (void)luaui_startLoading {
    SCROLLVIEW_DO(id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
                  MLNUIKitLuaAssert([delegate respondsToSelector:@selector(startLoadingOfRefreshView:)], @"-[refreshDelegate startLoadingOfRefreshView:] was not found!");
                  [delegate startLoadingOfRefreshView:scrollView];
                  )
}

- (void)setLuaui_refreshCallback:(MLNUIBlock *)luaui_refreshCallback
{
    MLNUICheckTypeAndNilValue(luaui_refreshCallback, @"callback", MLNUIBlock);
    SCROLLVIEW_DO(scrollView.luaui_refreshCallback = luaui_refreshCallback;)
}

- (MLNUIBlock *)luaui_refreshCallback {
    SCROLLVIEW_DO(return scrollView.luaui_refreshCallback;)
    return nil;
}

- (void)setLuaui_loadEnable:(BOOL)luaui_loadEnable
{
    SCROLLVIEW_DO(if (scrollView.luaui_loadEnable == luaui_loadEnable) {
        return;
    }
                  scrollView.luaui_loadEnable = luaui_loadEnable;
                  id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
                  if (luaui_loadEnable) {
                      MLNUIKitLuaAssert([delegate respondsToSelector:@selector(createFooterForRefreshView:)], @"-[refreshDelegate createFooterForRefreshView:] was not found!");
                      [delegate createFooterForRefreshView:scrollView];
                  } else {
                      MLNUIKitLuaAssert([delegate respondsToSelector:@selector(removeFooterForRefreshView:)], @"-[refreshDelegate removeFooterForRefreshView:] was not found!");
                      [delegate removeFooterForRefreshView:scrollView];
                  })
}

- (BOOL)luaui_loadEnable
{
    SCROLLVIEW_DO(return scrollView.luaui_loadEnable;)
    return NO;
}

- (BOOL)luaui_isLoading
{
    SCROLLVIEW_DO(id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
                  MLNUIKitLuaAssert([delegate respondsToSelector:@selector(isLoadingOfRefreshView:)], @"-[refreshDelegate isLoadingOfRefreshView:] was not found!");
                  return [delegate isLoadingOfRefreshView:scrollView];
                  )
    return NO;
}

- (void)setLuaui_loadahead:(CGFloat)luaui_loadahead {
    SCROLLVIEW_DO(MLNUIKitLuaAssert(luaui_loadahead >= 0, @"loadThreshold param must bigger or equal than 0.0!")
                  if (luaui_loadahead < 0) {
                      return;
                  }
                  scrollView.luaui_loadahead = luaui_loadahead;
                  )
}

- (CGFloat)luaui_loadahead {
    SCROLLVIEW_DO(return scrollView.luaui_loadahead)
    return 0.1;
}

- (void)luaui_stopLoading
{
    SCROLLVIEW_DO(id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
                  MLNUIKitLuaAssert([delegate respondsToSelector:@selector(stopLoadingOfRefreshView:)], @"-[refreshDelegate stopLoadingOfRefreshView:] was not found!");
                  [delegate stopLoadingOfRefreshView:scrollView];)
}

- (void)luaui_noMoreData
{
    SCROLLVIEW_DO(id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
                  MLNUIKitLuaAssert([delegate respondsToSelector:@selector(noMoreDataOfRefreshView:)], @"-[refreshDelegate noMoreDataOfRefreshView:] was not found!");
                  [delegate noMoreDataOfRefreshView:scrollView];)
}

- (void)luaui_resetLoading
{
    SCROLLVIEW_DO(id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
                  MLNUIKitLuaAssert([delegate respondsToSelector:@selector(resetLoadingOfRefreshView:)], @"-[refreshDelegate resetLoadingOfRefreshView:] was not found!");
                  [delegate resetLoadingOfRefreshView:scrollView];
                  )
}

- (BOOL)luaui_isNoMoreData
{
    SCROLLVIEW_DO(id<MLNUIRefreshDelegate> delegate = [self mlnui_getRefreshDelegate];
                  MLNUIKitLuaAssert([delegate respondsToSelector:@selector(isNoMoreDataOfRefreshView:)], @"-[refreshDelegate isNoMoreDataOfRefreshView:] was not found!");
                  return [delegate isNoMoreDataOfRefreshView:scrollView];
                  )
    return NO;
}

- (void)luaui_loadError
{
    // @note Android需要用到此方法，iOS空实现
}

- (void)setLuaui_loadCallback:(MLNUIBlock *)luaui_loadCallback
{
    MLNUICheckTypeAndNilValue(luaui_loadCallback, @"function", MLNUIBlock);
    SCROLLVIEW_DO(scrollView.luaui_loadCallback = luaui_loadCallback;)
}

- (MLNUIBlock *)luaui_loadCallback {
    SCROLLVIEW_DO(return scrollView.luaui_loadCallback;)
    return nil;
}

- (id<MLNUIRefreshDelegate>)mlnui_getRefreshDelegate
{
    return MLNUI_KIT_INSTANCE(self.mlnui_luaCore).instanceHandlersManager.scrollRefreshHandler;
}

- (void)setLuaui_scrollBeginCallback:(MLNUIBlock *)luaui_scrollBeginCallback
{
    SCROLLVIEW_DO(scrollView.luaui_scrollBeginCallback = luaui_scrollBeginCallback;)
}

- (MLNUIBlock *)luaui_scrollBeginCallback
{
    SCROLLVIEW_DO(return scrollView.luaui_scrollBeginCallback;)
    return nil;
}

- (void)setLuaui_scrollingCallback:(MLNUIBlock *)luaui_scrollingCallback
{
    MLNUICheckTypeAndNilValue(luaui_scrollingCallback, @"function", MLNUIBlock);
    SCROLLVIEW_DO(scrollView.luaui_scrollingCallback = luaui_scrollingCallback;)
}

- (MLNUIBlock *)luaui_scrollingCallback
{
    SCROLLVIEW_DO(return scrollView.luaui_scrollingCallback;)
    return nil;
}

- (void)setLuaui_scrollEndCallback:(MLNUIBlock *)luaui_scrollEndCallback
{
    MLNUICheckTypeAndNilValue(luaui_scrollEndCallback, @"function", MLNUIBlock);
    SCROLLVIEW_DO(scrollView.luaui_scrollEndCallback = luaui_scrollEndCallback;)
}

- (MLNUIBlock *)luaui_scrollEndCallback
{
    SCROLLVIEW_DO(return scrollView.luaui_scrollEndCallback);
    return nil;
}

- (void)setLuaui_startDeceleratingCallback:(MLNUIBlock *)luaui_startDeceleratingCallback
{
    MLNUICheckTypeAndNilValue(luaui_startDeceleratingCallback, @"function", MLNUIBlock);
    SCROLLVIEW_DO(scrollView.luaui_startDeceleratingCallback = luaui_startDeceleratingCallback;)
}

- (MLNUIBlock *)luaui_startDeceleratingCallback
{
    SCROLLVIEW_DO(return scrollView.luaui_startDeceleratingCallback;)
    return nil;
}

- (void)setLuaui_scrollWillEndDraggingCallback:(MLNUIBlock *)luaui_scrollWillEndDraggingCallback {
    MLNUICheckTypeAndNilValue(luaui_scrollWillEndDraggingCallback, @"function", MLNUIBlock);
    SCROLLVIEW_DO(scrollView.luaui_scrollWillEndDraggingCallback = luaui_scrollWillEndDraggingCallback;)
}

- (MLNUIBlock *)luaui_scrollWillEndDraggingCallback {
    SCROLLVIEW_DO(return scrollView.luaui_scrollWillEndDraggingCallback;)
    return nil;
}

- (void)setLuaui_endDraggingCallback:(MLNUIBlock *)luaui_endDraggingCallback
{
    MLNUICheckTypeAndNilValue(luaui_endDraggingCallback, @"function", MLNUIBlock);
    SCROLLVIEW_DO(scrollView.luaui_endDraggingCallback = luaui_endDraggingCallback;)
}

- (MLNUIBlock *)luaui_endDraggingCallback
{
    SCROLLVIEW_DO(return scrollView.luaui_endDraggingCallback;)
    return nil;
}

- (void)luaui_setContentInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    SCROLLVIEW_DO(scrollView.contentInset = UIEdgeInsetsMake(top, left, bottom, right);
                  if (UIEdgeInsetsEqualToEdgeInsets(scrollView.scrollIndicatorInsets, UIEdgeInsetsZero)) {
                      scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(top, left, bottom, right);
                  })
}

- (void)luaui_getContetnInset:(MLNUIBlock*)block
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

- (void)recalculContentSizeIfNeed
{
    SCROLLVIEW_DO(CGSize contentSize = scrollView.contentSize;
                  if (!scrollView.mlnui_horizontal) {
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

#pragma mark - iOS私有方法
- (CGPoint)luaui_contentOffset
{
    SCROLLVIEW_DO(return scrollView.contentOffset;)
    return CGPointZero;
}

- (void)luaui_setContentOffset:(CGPoint)point
{
    SCROLLVIEW_DO(if(scrollView.mlnui_horizontal) {
        [scrollView setContentOffset:CGPointMake(point.x, 0)];
    } else {
        [scrollView setContentOffset:CGPointMake(0, point.y)];
    })
}

- (void)luaui_setBounces:(BOOL)bouces
{
    SCROLLVIEW_DO(scrollView.bounces = bouces;)
}

- (BOOL)luaui_bounces
{
    SCROLLVIEW_DO(return scrollView.bounces);
    return NO;
}

- (void)luaui_setAlwaysBounceHorizontal:(BOOL)bouces
{
    SCROLLVIEW_DO(scrollView.alwaysBounceHorizontal = bouces;)
}

- (BOOL)luaui_alwaysBounceHorizontal
{
    SCROLLVIEW_DO(return scrollView.alwaysBounceHorizontal);
    return NO;
}

- (void)luaui_setAlwaysBounceVertical:(BOOL)bouces
{
    SCROLLVIEW_DO(scrollView.alwaysBounceVertical = bouces;)
}

- (BOOL)luaui_alwaysBounceVertical
{
    SCROLLVIEW_DO(return scrollView.alwaysBounceVertical);
    return NO;
}

- (void)luaui_setScrollIndicatorInset:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom  left:(CGFloat)left
{
    SCROLLVIEW_DO(scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(top, left, bottom, right);)
}

- (void)luaui_setContentOffsetWithAnimation:(CGPoint)point
{
    SCROLLVIEW_DO(if(scrollView.mlnui_horizontal) {
        [scrollView setContentOffset:CGPointMake(point.x, 0) animated:YES];
    } else {
        [scrollView setContentOffset:CGPointMake(0, point.y) animated:YES];
    })
}

- (void)luaui_setPagerContentOffset:(CGFloat)x y:(CGFloat)y {
    SCROLLVIEW_DO(if(scrollView.mlnui_horizontal) {
        [scrollView setContentOffset:CGPointMake(x, 0)];
    } else {
        [scrollView setContentOffset:CGPointMake(0, y)];
    })
}

@end
