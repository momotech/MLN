//
//  MLNGalleryMineViewController.m
//  MLN_Example
//
//  Created by Feng on 2019/11/5.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMineViewController.h"
#import "MLNGalleryNavigationBar.h"
#import "MLNGalleryMineInfoViewModel.h"
#import "MLNGalleryMineHeaderView.h"
#import "MLNNativeTabSegmentView.h"
#import "MLNGalleryMineBottomPage.h"
#import "MLNGalleryMineBottomCellModel.h"

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
    MLNGalleryMineBottomCellModel *info1 = [[MLNGalleryMineBottomCellModel alloc] init];
    info1.picture = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573142564082&di=b8df1e2ef7c0a46b04cfffcb05f9c73d&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201807%2F28%2F20180728175640_ejtpq.thumb.700_0.jpg";
    MLNGalleryMineBottomCellModel *info2 = [[MLNGalleryMineBottomCellModel alloc] init];
    info2.picture = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573142564082&di=2c6b33191e2d1c2c68c8dbed87133836&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201803%2F09%2F20180309131557_lhpgm.thumb.700_0.jpg";
    MLNGalleryMineBottomCellModel *info3 = [[MLNGalleryMineBottomCellModel alloc] init];
    info3.picture = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573142564081&di=1f3f6e1f96dcf84bdf5d60745e8894d5&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201808%2F22%2F20180822135332_evddv.thumb.700_0.jpg";
    self.pageView.bottomModels = @[info1, info2, info3];
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
