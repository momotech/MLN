//
//  MLNDiscoverAlbumDetailViewController.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/8.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNDiscoverAlbumDetailViewController.h"
#import "MLNNativeWaterfallView.h"
#import "MLNNativeWaterfallLayout.h"
#import "MLNGalleryNative.h"
#import "MLNNativeWaterfallLayoutDelegate.h"
#import "MLNGalleryNavigationBar.h"
#import "MLNDiscoverAblbumDeatilHeaderView.h"
#import "MLNMyHttpHandler.h"
#import <UIView+Toast.h>
#import "MLNDiscoverAlbumDetailCell.h"

@interface MLNDiscoverAlbumDetailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, MLNNativeWaterfallLayoutDelegate>
@property (nonatomic, strong) MLNGalleryNavigationBar *navigationBar;
@property (nonatomic, strong) MLNNativeWaterfallView *waterfallView;
@property (nonatomic, strong) MLNMyHttpHandler *myHttpHandler;
@property (nonatomic, assign) NSInteger requestPageIndex;
@property (nonatomic, strong) NSMutableArray *dataList;
@end

static NSString *kMLNDiscoverDetailHeaderID = @"kMLNDiscoverDetailHeaderID";
static NSString *kMLNDiscoverDetailCellID = @"kMLNDiscoverDetailCellID";

@implementation MLNDiscoverAlbumDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setTitle:@"灵感集"];
    [self requestInspirData];
    [self waterfallView];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MLNDiscoverAlbumDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMLNDiscoverDetailCellID forIndexPath:indexPath];
    [cell reloadWithData:self.dataList[indexPath.row]];
    return cell;
}


#pragma mark - MLNNativeWaterfallLayoutDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(kScreenWidth, 200);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    MLNDiscoverAblbumDeatilHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMLNDiscoverDetailHeaderID forIndexPath:indexPath];
    [headerView reloadWithData:self.dataList];
    __weak typeof(self) weakSelf = self;
    headerView.selectBlock = ^{
        [weakSelf requestInspirData];
    };
    return headerView;
}

#pragma mark - Private method
- (MLNNativeWaterfallView *)waterfallView
{
    if (!_waterfallView) {
        MLNNativeWaterfallLayout *layout = [[MLNNativeWaterfallLayout alloc] init];
        layout.itemSpacing = 10;
        layout.lineSpacing = 10;
        layout.delegate = self;
        _waterfallView = [[MLNNativeWaterfallView alloc] initWithFrame:CGRectMake(0, kNaviBarHeight, kScreenWidth, kScreenHeight - kNaviBarHeight) collectionViewLayout:layout];
        _waterfallView.backgroundColor = [UIColor whiteColor];
        _waterfallView.dataSource = self;
        _waterfallView.delegate = self;
        [_waterfallView registerClass:[MLNDiscoverAlbumDetailCell class] forCellWithReuseIdentifier:kMLNDiscoverDetailCellID];
        [_waterfallView registerClass:[MLNDiscoverAblbumDeatilHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMLNDiscoverDetailHeaderID];
        [self.view addSubview:_waterfallView];
    }
    return _waterfallView;
}


#pragma mark - request
- (void)requestInspirData
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    NSString *requestUrlString = @"https://api.apiopen.top/musicRankingsDetails";
    NSArray *pageIdx = @[@13, @9, @11, @12, @6];
    NSInteger requestPageIdx = random()%5;
    self.requestPageIndex = [pageIdx[requestPageIdx] integerValue];
    [self.myHttpHandler http:nil get:requestUrlString params:@{@"type":@(self.requestPageIndex)} completionHandler:^(BOOL success, NSDictionary * _Nonnull respose, NSDictionary * _Nonnull error) {
        NSLog(@"-------> response:%@", respose);
        if (!success) {
            [self.view makeToast:error.description
                        duration:3.0
                        position:CSToastPositionCenter];
            return;
        }
        
        NSArray *dataArray = [respose valueForKey:@"result"];
        [self.dataList addObjectsFromArray:dataArray];
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
        MLNGalleryNavigationBarItem *leftItem = [[MLNGalleryNavigationBarItem alloc] init];
        leftItem.image = [UIImage imageNamed:@"1567316383505-minmore"];
        [self.navigationBar setLeftItem:leftItem];
        __weak typeof(self) weakSelf = self;
        leftItem.clickActionBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        
        MLNGalleryNavigationBarItem *rightItem = [[MLNGalleryNavigationBarItem alloc] init];
        rightItem.image = [UIImage imageNamed:@"1567316383469-minshare"];
        [self.navigationBar setRightItem:rightItem];
        rightItem.clickActionBlock = ^{
            NSLog(@"点击了分享按钮！！");
        };
        [self.view addSubview:_navigationBar];
    }
    return _navigationBar;
}

@end
