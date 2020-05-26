//
//  MLNUIRefreshDelegate.h
//  Pods
//
//  Created by MoMo on 2018/7/19.
//

#ifndef MLNUIRefreshDelegate_h
#define MLNUIRefreshDelegate_h
#import <UIKit/UIKit.h>

@class MLNUIBlock;
@protocol MLNUIRefreshDelegate <NSObject>

// header
- (void)createHeaderForRefreshView:(UIScrollView *)refreshView;
- (BOOL)isRefreshingOfRefreshView:(UIScrollView *)refreshView;
- (void)startRefreshingOfRefreshView:(UIScrollView *)refreshView;
- (void)stopRefreshingOfRefreshView:(UIScrollView *)refreshView;
- (void)removeHeaderForRefreshView:(UIScrollView *)refreshView;
- (void)refreshView:(UIScrollView *)refreshView setRefreshingCallback:(MLNUIBlock *)callback;

// footer
- (void)createFooterForRefreshView:(UIScrollView *)refreshView;
- (BOOL)isLoadingOfRefreshView:(UIScrollView *)refreshView;
- (void)startLoadingOfRefreshView:(UIScrollView *)refreshView;
- (void)stopLoadingOfRefreshView:(UIScrollView *)refreshView;
- (void)noMoreDataOfRefreshView:(UIScrollView *)refreshView;
- (void)resetLoadingOfRefreshView:(UIScrollView *)refreshView;
- (void)removeFooterForRefreshView:(UIScrollView *)refreshView;
- (BOOL)isNoMoreDataOfRefreshView:(UIScrollView *)refreshView;
- (void)refreshView:(UIScrollView *)refreshView setLoadingCallback:(MLNUIBlock *)callback;

@end

#endif 
