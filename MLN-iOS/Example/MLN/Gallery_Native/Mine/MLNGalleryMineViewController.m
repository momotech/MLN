//
//  MLNGalleryMineViewController.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/5.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNGalleryMineViewController.h"
#import "MLNGalleryNavigationBar.h"
#import "MLNGalleryMineInfoViewModel.h"
#import "MLNGalleryMineHeaderView.h"
#import "MLNNativeTabSegmentView.h"
#import "MLNGalleryMineBottomPage.h"
#import "MLNLoadTimeStatistics.h"
#import "MLNGalleryMinePageCellHomeModel.h"
#import "MLNGalleryMinePageCellDynamicModel.h"
#import "MLNGalleryMinePageCellCollectModel.h"

@interface MLNGalleryMineViewController ()

@property (nonatomic, strong) MLNGalleryNavigationBar *navigationBar;

@property (nonatomic, strong) MLNGalleryMineHeaderView *headerView;

@property (nonatomic, strong) MLNNativeTabSegmentView *segementView;

@property (nonatomic, strong) MLNGalleryMineBottomPage *pageView;

@end

@implementation MLNGalleryMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    初始化导航栏
    [self setupNavigation];
//    初始化我的信息页
    [self setupMineInfoView];
//    初始化标签栏
    [self segementView];
//    初始化page页
    [self setupPageView];
}

- (void)setupNavigation
{
    [self.navigationBar setTitle:@"我的"];
    
    MLNGalleryNavigationBarItem *leftItem = [[MLNGalleryNavigationBarItem alloc] init];
    leftItem.image = [UIImage imageNamed:@"1567316383505-minmore"];
    [self.navigationBar setLeftItem:leftItem];
//    __weak typeof(self) weakSelf = self;
    leftItem.clickActionBlock = ^{
//        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"点击了更多按钮！！");
    };
    
    MLNGalleryNavigationBarItem *rightItem = [[MLNGalleryNavigationBarItem alloc] init];
    rightItem.image = [UIImage imageNamed:@"1567316383469-minshare"];
    [self.navigationBar setRightItem:rightItem];
    rightItem.clickActionBlock = ^{
        NSLog(@"点击了分享按钮！！");
    };
    
}

- (void)setupMineInfoView
{
    _mineInfoModel = [[MLNGalleryMineInfoViewModel alloc] init];
    _mineInfoModel.avatar = @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1573132480&di=98ea17c8ac6593b08325a14dcb4eea53&src=http://pic.qqtn.com/up/2017-12/2017120108345974006.jpg";
    _mineInfoModel.name = @"北京迪丽热巴";
    _mineInfoModel.location = @"北京-朝阳";
    
    MLNGalleryMineInfoNumberViewModel *model1 = [[MLNGalleryMineInfoNumberViewModel alloc] initWithDesc:@"粉丝" number:80985];
    MLNGalleryMineInfoNumberViewModel *model2 = [[MLNGalleryMineInfoNumberViewModel alloc] initWithDesc:@"关注" number:2];
    MLNGalleryMineInfoNumberViewModel *model3 = [[MLNGalleryMineInfoNumberViewModel alloc] initWithDesc:@"赞和收藏" number:209292];
    _mineInfoModel.infoNumbers = @[model1, model2, model3];
    
    _mineInfoModel.clickTitle = @"编辑资料";
    _mineInfoModel.clickActionBlock = ^{
        NSLog(@"点击了编辑资料");
    };
    
    
    self.headerView.mineInfoModel = _mineInfoModel;
}

- (void)setupPageView
{
    MLNGalleryMinePageCellHomeModel *homeModel = [[MLNGalleryMinePageCellHomeModel alloc] init];
    homeModel.picture = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573142564082&di=b8df1e2ef7c0a46b04cfffcb05f9c73d&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201807%2F28%2F20180728175640_ejtpq.thumb.700_0.jpg";
    
    MLNGalleryMinePageCellDynamicModel *dynamicModel = [[MLNGalleryMinePageCellDynamicModel alloc] init];
    dynamicModel.day = @"2019-11-11";
    dynamicModel.date = @"10:06";
    dynamicModel.picture = @"http://www.xiangxiangmf.com/uploads/2018-01/12-200106_404.jpg";
    
    MLNGalleryMinePageCellCollectModel *collectModel = [[MLNGalleryMinePageCellCollectModel alloc] init];
    collectModel.title = @"我的灵感集";
    collectModel.buttonTitle = @"+新建";
    
    MLNGalleryMinePageCellCollectCellModel *model1 = [[MLNGalleryMinePageCellCollectCellModel alloc] init];
    model1.avatar = @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1573132480&di=98ea17c8ac6593b08325a14dcb4eea53&src=http://pic.qqtn.com/up/2017-12/2017120108345974006.jpg";
    model1.title = @"美丽";
    model1.desc = @"1篇内容 | 1人浏览";
    model1.righticon  = @"https://s.momocdn.com/w/u/others/2019/08/31/1567264720561-rightarrow.png";
    collectModel.dataCellModels = @[model1];
    
    self.pageView.bottomModels = @[homeModel, dynamicModel, collectModel];
}


#pragma mark - action
- (void)segmentViewDidSelected:(MLNNativeTabSegmentView *)tapView index:(NSInteger)index
{
    [self.pageView scrollToPage:index];
}


#pragma mark - getter
- (MLNGalleryNavigationBar *)navigationBar
{
    if (!_navigationBar) {
        _navigationBar = [[MLNGalleryNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kMLNNavigatorHeight)];
        [self.view addSubview:_navigationBar];
    }
    return _navigationBar;
}

- (MLNGalleryMineHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [[MLNGalleryMineHeaderView alloc] initWithFrame:CGRectMake(0, kMLNNavigatorHeight + 20, self.view.frame.size.width, 180)];
        [self.view addSubview:_headerView];
    }
    return _headerView;
}

- (MLNNativeTabSegmentView *)segementView
{
    if (!_segementView) {
        NSArray *titles = @[@"主页", @"动态", @"收藏"];
        __weak typeof(self) weakSelf = self;
        _segementView = [[MLNNativeTabSegmentView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame) + 1, self.view.frame.size.width, 50) segmentTitles:titles tapBlock:^(MLNNativeTabSegmentView * _Nonnull tapView, NSInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf segmentViewDidSelected:tapView index:index];
        }];
        [_segementView lua_setAlignment:MLNNativeTabSegmentAlignmentCenter];
        [self.view addSubview:_segementView];
    }
    return _segementView;
}

- (MLNGalleryMineBottomPage *)pageView
{
    if (!_pageView) {
        CGFloat maxY = CGRectGetMaxY(self.segementView.frame);
        CGFloat heigth = self.view.frame.size.height - maxY;
        _pageView = [[MLNGalleryMineBottomPage alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.segementView.frame) , self.view.frame.size.width, heigth)];
        _pageView.segmentViewHandler = (id<UIScrollViewDelegate>)self.segementView.scrollHandler;
        [self.view addSubview:_pageView];
    }
    return _pageView;
}

@end
