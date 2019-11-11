//
//  MLNGalleryHomeViewController.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/5.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNGalleryHomeViewController.h"
#import "MLNNativeTabSegmentView.h"
#import "MLNGalleryNative.h"
#import "MLNSimpleViewPager.h"
#import "MLNMyHttpHandler.h"
#import "MLNHomeDataHandler.h"
#import "UIView+Toast.h"
#import <MJRefresh.h>
#import <MLNLoadTimeStatistics.h>

@interface MLNGalleryHomeViewController ()
@property (nonatomic, strong) MLNNativeTabSegmentView *segementView;
@property (nonatomic, strong) MLNSimpleViewPager *viewPager;
@property (nonatomic, strong) MLNMyHttpHandler *myHttpHandler;
@property (nonatomic, assign) NSInteger mid;
@property (nonatomic, assign) NSInteger cid;
@end

@implementation MLNGalleryHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:redView];

    [self setupSubviews];
    [self requestData:YES];
}

- (void)setupSubviews
{
    NSArray *tiltles = @[@"关注",@"推荐"];
    self.segementView = [[MLNNativeTabSegmentView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNaviBarHeight) segmentTitles:tiltles tapBlock:^(MLNNativeTabSegmentView * _Nonnull tapView, NSInteger index) {
        [self.viewPager scrollToPage:index aniamted:YES];
    }];
    self.segementView.frame = CGRectMake(0, 0, kScreenWidth, kNaviBarHeight);
    self.segementView.backgroundColor = [UIColor whiteColor];
    [self.segementView lua_setAlignment:MLNNativeTabSegmentAlignmentCenter];
    [self.view addSubview:self.segementView];
    
    self.viewPager = [[MLNSimpleViewPager alloc] initWithFrame:CGRectMake(0, kNaviBarHeight, kScreenWidth, kScreenHeight - kNaviBarHeight - kTabbBarHeight)];
    self.viewPager.segmentViewHandler = (id<UIScrollViewDelegate>)self.segementView.scrollHandler;;
//    self.viewPager.mainView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
//    self.viewPager.mainView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    __weak typeof(self) weakSelf = self;
    [self.viewPager setSearchBlock:^{
        [weakSelf.view makeToast:@"网红咖啡馆"
                        duration:2.0
                        position:CSToastPositionCenter];
    }];
    [self.view addSubview:self.viewPager];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[MLNLoadTimeStatistics sharedInstance] recordEndTime];
    NSLog(@">>>>>>>>>>>>>>>>>loadTime:%@", @([[MLNLoadTimeStatistics sharedInstance] allLoadTime] * 1000));
}


- (void)loadMoreData
{
    [self requestData:NO];
}

- (void)loadNewData
{
    [self requestData:YES];
}

- (void)requestData:(BOOL)firstRequest
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    NSString *requestUrlString = @"http://v2.api.haodanku.com/itemlist/apikey/fashion/cid/1/back/20";
    [self.myHttpHandler http:nil get:requestUrlString params:@{@"mid":@(self.mid), @"cid":@(self.cid)} completionHandler:^(BOOL success, NSDictionary * _Nonnull respose, NSDictionary * _Nonnull error) {
        NSLog(@"-------> response:%@", respose);
        if (!success) {
            [self.view makeToast:error.description
                        duration:3.0
                        position:CSToastPositionCenter];
            return;
        }
        if (firstRequest) {
            NSArray *dataList = [respose valueForKey:@"data"];
            [[MLNHomeDataHandler handler] updateDataList:dataList];
            [self.viewPager.mainView.mj_header endRefreshing];
        } else if ([MLNHomeDataHandler handler].dataList.count >= 40) {
            [self.viewPager.mainView.mj_footer endRefreshingWithNoMoreData];
        } else {
            NSArray *dataList = [respose valueForKey:@"data"];
            [[MLNHomeDataHandler handler] insertDataList:dataList];
            [self.viewPager.mainView.mj_header endRefreshing];
        }
        [self.viewPager reloadWithDataList:[MLNHomeDataHandler handler].dataList];
    }];
#pragma clang diagnostic pop
}

- (MLNMyHttpHandler *)myHttpHandler
{
    if (!_myHttpHandler) {
        _myHttpHandler = [[MLNMyHttpHandler alloc] init];
    }
    return _myHttpHandler;
}

@end
