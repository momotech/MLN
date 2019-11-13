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

@end

@implementation MLNGalleryHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 1)];
    placeholderView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:placeholderView];
    
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
    [self.view addSubview:self.viewPager];
}

@end
