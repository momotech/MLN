//
//  MLNUIScrollViewDelegate.m
//  Expecta
//
//  Created by MoMo on 2018/7/5.
//

#import "MLNUIScrollViewDelegate.h"
#import "UIScrollView+MLNUIKit.h"
#import "MLNUIBlock.h"

@implementation MLNUIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.lua_scrollBeginCallback) {
        [scrollView.lua_scrollBeginCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.lua_scrollBeginCallback addFloatArgument:scrollView.contentOffset.y];
        [scrollView.lua_scrollBeginCallback callIfCan];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.lua_scrollingCallback) {
        [scrollView.lua_scrollingCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.lua_scrollingCallback addFloatArgument:scrollView.contentOffset.y];
        [scrollView.lua_scrollingCallback callIfCan];
    }
    
    if (scrollView.lua_loadahead > 0 && !scrollView.lua_isLoading) {
        if (!scrollView.mln_horizontal) {
            if (scrollView.contentSize.height - scrollView.contentOffset.y <= scrollView.frame.size.height * (scrollView.lua_loadahead + 1)) {
                CGFloat value = ( scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height)/scrollView.frame.size.height;
                if (value <= scrollView.lua_loadahead && ![scrollView lua_isNoMoreData]) {
                    [scrollView lua_startLoading];
                }
            }
        } else {
            if (scrollView.contentSize.width - scrollView.contentOffset.x <= scrollView.frame.size.width * (scrollView.lua_loadahead + 1)) {
                CGFloat value = ( scrollView.contentSize.width - scrollView.contentOffset.x - scrollView.frame.size.width)/scrollView.frame.size.width;
                if (value <= scrollView.lua_loadahead && ![scrollView lua_isNoMoreData]) {
                    [scrollView lua_startLoading];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.lua_endDraggingCallback) {
        [scrollView.lua_endDraggingCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.lua_endDraggingCallback addFloatArgument:scrollView.contentOffset.y];
        [scrollView.lua_endDraggingCallback addBOOLArgument:decelerate];
        [scrollView.lua_endDraggingCallback callIfCan];
    }
    if (!decelerate && scrollView.lua_scrollEndCallback) {
        [scrollView.lua_scrollEndCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.lua_scrollEndCallback addFloatArgument:scrollView.contentOffset.y];
        [self calculateTopOrBottom:scrollView block:scrollView.lua_scrollEndCallback];
        
        [scrollView.lua_scrollEndCallback callIfCan];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.lua_startDeceleratingCallback) {
        [scrollView.lua_startDeceleratingCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.lua_startDeceleratingCallback addFloatArgument:scrollView.contentOffset.y];
        [scrollView.lua_startDeceleratingCallback callIfCan];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.lua_scrollEndCallback) {
        [scrollView.lua_scrollEndCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.lua_scrollEndCallback addFloatArgument:scrollView.contentOffset.y];
        [self calculateTopOrBottom:scrollView block:scrollView.lua_scrollEndCallback];
        [scrollView.lua_scrollEndCallback callIfCan];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.lua_scrollEndCallback) {
        [scrollView.lua_scrollEndCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.lua_scrollEndCallback addFloatArgument:scrollView.contentOffset.y];
        [self calculateTopOrBottom:scrollView block:scrollView.lua_scrollEndCallback];
        [scrollView.lua_scrollEndCallback callIfCan];
    }
}

#pragma mark - PrivateMethod
- (void)calculateTopOrBottom:(UIScrollView *)scrollV block:(MLNUIBlock *)block
{
    if (!block) {
        return;
    }
    BOOL vertical = YES;
    if (scrollV.contentSize.width > scrollV.frame.size.width) {
        vertical = NO;
    }
    if (vertical) {
        CGFloat top = scrollV.contentInset.top;
        CGFloat bottom = scrollV.contentInset.bottom;
        if(scrollV.contentOffset.y + top == 0)
        {
            [block addIntArgument:1];
        } else if (scrollV.contentOffset.y + scrollV.frame.size.height - bottom == scrollV.contentSize.height) {
            [block addIntArgument:2];
        } else {
            [block addIntArgument:-1];
        }
    } else {
        CGFloat left = scrollV.contentInset.left;
        CGFloat right = scrollV.contentInset.right;
        if(scrollV.contentOffset.x + left == 0)
        {
            [block addIntArgument:1];
        } else if (scrollV.contentOffset.x + scrollV.frame.size.width - right == scrollV.contentSize.width) {
            [block addIntArgument:2];
        } else {
            [block addIntArgument:-1];
        }
    }
}

@end
