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
    if (scrollView.luaui_scrollBeginCallback) {
        [scrollView.luaui_scrollBeginCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.luaui_scrollBeginCallback addFloatArgument:scrollView.contentOffset.y];
        [scrollView.luaui_scrollBeginCallback callIfCan];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.luaui_scrollingCallback) {
        [scrollView.luaui_scrollingCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.luaui_scrollingCallback addFloatArgument:scrollView.contentOffset.y];
        [scrollView.luaui_scrollingCallback callIfCan];
    }
    
    if (scrollView.luaui_loadahead > 0 && !scrollView.luaui_isLoading) {
        if (!scrollView.mlnui_horizontal) {
            if (scrollView.contentSize.height - scrollView.contentOffset.y <= scrollView.frame.size.height * (scrollView.luaui_loadahead + 1)) {
                CGFloat value = ( scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height)/scrollView.frame.size.height;
                if (value <= scrollView.luaui_loadahead && ![scrollView luaui_isNoMoreData]) {
                    [scrollView luaui_startLoading];
                }
            }
        } else {
            if (scrollView.contentSize.width - scrollView.contentOffset.x <= scrollView.frame.size.width * (scrollView.luaui_loadahead + 1)) {
                CGFloat value = ( scrollView.contentSize.width - scrollView.contentOffset.x - scrollView.frame.size.width)/scrollView.frame.size.width;
                if (value <= scrollView.luaui_loadahead && ![scrollView luaui_isNoMoreData]) {
                    [scrollView luaui_startLoading];
                }
            }
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView.luaui_disallowFling) { // 让scrollView停在手指离开屏幕的位置
        *targetContentOffset = scrollView.contentOffset;
    }

    if (scrollView.luaui_scrollWillEndDraggingCallback) {
        [scrollView.luaui_scrollWillEndDraggingCallback addFloatArgument:velocity.y];
        [scrollView.luaui_scrollWillEndDraggingCallback callIfCan];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.luaui_endDraggingCallback) {
        [scrollView.luaui_endDraggingCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.luaui_endDraggingCallback addFloatArgument:scrollView.contentOffset.y];
        [scrollView.luaui_endDraggingCallback addBOOLArgument:decelerate];
        [scrollView.luaui_endDraggingCallback callIfCan];
    }
    if (!decelerate && scrollView.luaui_scrollEndCallback) {
        [scrollView.luaui_scrollEndCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.luaui_scrollEndCallback addFloatArgument:scrollView.contentOffset.y];
        [self calculateTopOrBottom:scrollView block:scrollView.luaui_scrollEndCallback];
        
        [scrollView.luaui_scrollEndCallback callIfCan];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.luaui_startDeceleratingCallback) {
        [scrollView.luaui_startDeceleratingCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.luaui_startDeceleratingCallback addFloatArgument:scrollView.contentOffset.y];
        [scrollView.luaui_startDeceleratingCallback callIfCan];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.luaui_scrollEndCallback) {
        [scrollView.luaui_scrollEndCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.luaui_scrollEndCallback addFloatArgument:scrollView.contentOffset.y];
        [self calculateTopOrBottom:scrollView block:scrollView.luaui_scrollEndCallback];
        [scrollView.luaui_scrollEndCallback callIfCan];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.luaui_scrollEndCallback) {
        [scrollView.luaui_scrollEndCallback addFloatArgument:scrollView.contentOffset.x];
        [scrollView.luaui_scrollEndCallback addFloatArgument:scrollView.contentOffset.y];
        [self calculateTopOrBottom:scrollView block:scrollView.luaui_scrollEndCallback];
        [scrollView.luaui_scrollEndCallback callIfCan];
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
