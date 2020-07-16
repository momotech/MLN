//
//  MLNMyRefreshHandler.m
//  MLN_Example
//
//  Created by MoMo on 2019/9/2.
//  Copyright © 2019 MoMo. All rights reserved.
//

#import "MLNMyRefreshHandler.h"
#import <MJRefresh.h>
#import "MLNUIKit.h"

@implementation MLNMyRefreshHandler

// header
- (void)createHeaderForRefreshView:(UIScrollView *)refreshView
{
    __weak typeof(refreshView) weakRefreshView = refreshView;
    refreshView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (weakRefreshView.lua_refreshCallback) {
            [weakRefreshView.lua_refreshCallback callIfCan];
        }
        if (weakRefreshView.luaui_refreshCallback) {
            [weakRefreshView.luaui_refreshCallback callIfCan];
        }
    }];
}

- (BOOL)isRefreshingOfRefreshView:(UIScrollView *)refreshView
{
    return refreshView.mj_header.isRefreshing;
}

- (void)startRefreshingOfRefreshView:(UIScrollView *)refreshView
{
    [refreshView.mj_header beginRefreshing];
}

- (void)stopRefreshingOfRefreshView:(UIScrollView *)refreshView
{
    [refreshView.mj_header endRefreshing];
}

- (void)startLoadingOfRefreshView:(UIScrollView *)refreshView {
    [refreshView.mj_footer beginRefreshing];
}


- (void)removeHeaderForRefreshView:(UIScrollView *)refreshView
{
    refreshView.mj_header = nil;
}

// footer
- (void)createFooterForRefreshView:(UIScrollView *)refreshView
{
    __weak typeof(refreshView) weakRefreshView = refreshView;
    refreshView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (weakRefreshView.lua_loadCallback) {
            [weakRefreshView.lua_loadCallback callIfCan];
        }
        if (weakRefreshView.luaui_loadCallback) {
            [weakRefreshView.luaui_loadCallback callIfCan];
        }
    }];
}

- (BOOL)isLoadingOfRefreshView:(UIScrollView *)refreshView
{
    return refreshView.mj_footer.isRefreshing;
}

- (void)stopLoadingOfRefreshView:(UIScrollView *)refreshView
{
    [refreshView.mj_footer endRefreshing];
}

- (void)noMoreDataOfRefreshView:(UIScrollView *)refreshView
{
    [refreshView.mj_footer endRefreshingWithNoMoreData];
}

- (void)resetLoadingOfRefreshView:(UIScrollView *)refreshView
{
    [refreshView.mj_footer resetNoMoreData];
}

- (void)removeFooterForRefreshView:(UIScrollView *)refreshView
{
    refreshView.mj_footer = nil;
}

- (BOOL)isNoMoreDataOfRefreshView:(UIScrollView *)refreshView
{
    return refreshView.mj_footer.state == MJRefreshStateNoMoreData;
}

- (void)refreshView:(UIScrollView *)refreshView setLoadingCallback:(MLNBlock *)callback
{
    refreshView.lua_loadCallback = callback;
}

- (void)refreshView:(UIScrollView *)refreshView setRefreshingCallback:(MLNBlock *)callback
{
    refreshView.lua_refreshCallback = callback;
}

@end
