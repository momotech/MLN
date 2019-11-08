//
//  MLNGalleryDiscoverViewController.m
//  MLN_Example
//
//  Created by Feng on 2019/11/5.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
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
    [self requestDiscoverData];
    [self waterfallView];
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


#pragma mark - MLNNativeWaterfallLayoutDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 280;
    }
    
    return 300;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(kScreenWidth, 310);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    MLNNativeWaterfallHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMLNNativeWaterfallViewHeaderID forIndexPath:indexPath];
    [headerView reloadWithData:nil];
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
        [_waterfallView registerClass:[MLNNativeWaterfallViewCell class] forCellWithReuseIdentifier:kMLNNativeWaterfallViewCellID];
        [_waterfallView registerClass:[MLNNativeWaterfallHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMLNNativeWaterfallViewHeaderID];
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
- (void)requestDiscoverData
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
        [self.view addSubview:_navigationBar];
    }
    return _navigationBar;
}

@end
