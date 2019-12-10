//
//  MLNGalleryDiscoverViewController.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/5.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNGalleryDiscoverViewController.h"
#import "MLNNativeWaterfallView.h"
#import "MLNNativeWaterfallLayout.h"
#import "MLNNativeWaterfallViewCell.h"
#import "MLNGalleryNative.h"
#import "MLNNativeWaterfallLayoutDelegate.h"
#import "MLNGalleryNavigationBar.h"
#import "MLNNativeWaterfallHeaderView.h"
#import "MLNMyHttpHandler.h"
#import <UIView+Toast.h>
#import "MLNDiscoverAlbumDetailViewController.h"
#import <MJRefresh.h>
#import "MLNLoadTimeStatistics.h"

@interface MLNGalleryDiscoverViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, MLNNativeWaterfallLayoutDelegate>
@property (nonatomic, strong) MLNGalleryNavigationBar *navigationBar;
@property (nonatomic, strong) MLNNativeWaterfallView *waterfallView;
@property (nonatomic, strong) MLNNativeWaterfallHeaderView *waterfallHeaderView;
@property (nonatomic, strong) MLNMyHttpHandler *myHttpHandler;
@property (nonatomic, assign) NSInteger requestPageIndex;
@property (nonatomic, strong) NSMutableArray *dataList;
@end

static NSString *kMLNNativeWaterfallViewHeaderID = @"kMLNNativeWaterfallViewHeaderID";
static NSString *kMLNNativeWaterfallViewCellID = @"kMLNNativeWaterfallViewCellID";

@implementation MLNGalleryDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationBar setTitle:@"发现"];
    [self requestDiscoverData:YES];
    [self waterfallView];
}

#pragma mark - Actions
- (void)loadMoreData
{
    [self requestDiscoverData:NO];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MLNNativeWaterfallViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMLNNativeWaterfallViewCellID forIndexPath:indexPath];
    [cell reloadWithData:self.dataList[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"<<<<<<<<<<<<<<<<<<原生创建Controller");
    [[MLNLoadTimeStatistics sharedInstance] recordStartTime];
    MLNDiscoverAlbumDetailViewController *detailViewController = [[MLNDiscoverAlbumDetailViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark - MLNNativeWaterfallLayoutDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 260;
    }
    
    return 280;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(kScreenWidth, 310);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    MLNNativeWaterfallHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMLNNativeWaterfallViewHeaderID forIndexPath:indexPath];
    [headerView reloadWithData:@{}];
    return headerView;
}

#pragma mark - Private method
- (MLNNativeWaterfallView *)waterfallView
{
    if (!_waterfallView) {
        MLNNativeWaterfallLayout *layout = [[MLNNativeWaterfallLayout alloc] init];
        layout.layoutInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.itemSpacing = 10;
        layout.lineSpacing = 10;
        layout.delegate = self;
        _waterfallView = [[MLNNativeWaterfallView alloc] initWithFrame:CGRectMake(0, kNaviBarHeight, kScreenWidth, kScreenHeight - kNaviBarHeight) collectionViewLayout:layout];
        _waterfallView.backgroundColor = [UIColor whiteColor];
        _waterfallView.dataSource = self;
        _waterfallView.delegate = self;
        [_waterfallView registerClass:[MLNNativeWaterfallViewCell class] forCellWithReuseIdentifier:kMLNNativeWaterfallViewCellID];
        [_waterfallView registerClass:[MLNNativeWaterfallHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMLNNativeWaterfallViewHeaderID];
        _waterfallView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        [self.view addSubview:_waterfallView];
    }
    
    return _waterfallView;
}

- (MLNNativeWaterfallHeaderView *)waterfallHeaderView
{
    if (!_waterfallHeaderView) {
        _waterfallHeaderView = [[MLNNativeWaterfallHeaderView alloc] init];
    }
    return _waterfallHeaderView;
}


#pragma mark - request
- (void)requestDiscoverData:(BOOL)firstRequest
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    NSString *requestUrlString = @"https://api.apiopen.top/musicRankingsDetails";
    
    NSArray *pageIdx = @[@13, @9, @11, @12, @6];
    NSInteger requestPageIdx = random()%5;
    self.requestPageIndex = [pageIdx[requestPageIdx] integerValue];
    [self.myHttpHandler http:nil get:requestUrlString params:@{@"type":@(self.requestPageIndex)} completionHandler:^(BOOL success, NSDictionary * _Nonnull respose, NSDictionary * _Nonnull error) {
        if (!success) {
            [self.view makeToast:error.description
                        duration:3.0
                        position:CSToastPositionCenter];
            return;
        }
        
        if (firstRequest) {
            NSArray *dataArray = [respose valueForKey:@"result"];
            self.dataList = [NSMutableArray arrayWithArray:dataArray];
        } else if (self.dataList.count >= 200) {
            [self.waterfallView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.waterfallView.mj_footer endRefreshing];
            NSArray *dataArray = [respose valueForKey:@"result"];
            [self.dataList addObjectsFromArray:dataArray];
        }
        
        
        
        [self.waterfallView reloadData];
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

- (NSMutableArray *)dataList
{
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

- (MLNGalleryNavigationBar *)navigationBar
{
    if (!_navigationBar) {
        _navigationBar = [[MLNGalleryNavigationBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNaviBarHeight)];
        [self.view addSubview:_navigationBar];
    }
    return _navigationBar;
}

@end
