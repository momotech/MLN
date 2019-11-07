//
//  MLNGalleryHomeViewController.m
//  MLN_Example
//
//  Created by Feng on 2019/11/5.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryHomeViewController.h"
#import "MLNNativeTabSegmentView.h"
#import "MLNGalleryNative.h"
#import "MLNSimpleViewPager.h"
#import "MLNMyHttpHandler.h"
#import "MLNHomeDataHandler.h"
#import "UIView+Toast.h"
#import <MJRefresh.h>

@interface MLNGalleryHomeViewController ()
@property (nonatomic, strong) MLNNativeTabSegmentView *segementView;
@property (nonatomic, strong) MLNSimpleViewPager *viewPager;

// requst
@property (nonatomic, strong) MLNMyHttpHandler *myHttpHandler;
@property (nonatomic, assign) NSInteger mid;
@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, strong) NSArray *dataList;
@end

@implementation MLNGalleryHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSubviews];
    [self requestData];
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
    
    [self.viewPager setRefreshBlock:^(UITableView *tableView){
        [tableView.mj_header endRefreshing];
    }];
    
    [self.viewPager setLoadingBlock:^(UITableView *tableView){
    
    }];
    
    __weak typeof(self) weakSelf = self;
    [self.viewPager setSearchBlock:^{
        [weakSelf.view makeToast:@"网红咖啡馆"
                        duration:2.0
                        position:CSToastPositionCenter];
    }];
    [self.view addSubview:self.viewPager];
}

- (void)requestData
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
        self.dataList = [respose valueForKey:@"data"];
        [[MLNHomeDataHandler handler] updateDataList:self.dataList];
        [self.viewPager reloadWithDataList:self.dataList];
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
