//
//  MLNSimpleViewPager.m
//  MLN_Example
//
//  Created by Feng on 2019/11/6.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNSimpleViewPager.h"
#import "MLNSimpleViewPagerCell.h"
#import "MLNHomeTableView.h"

#define kMLNSimpleViewPagerCell  @"kMLNSimpleViewPagerCell"

@interface MLNSimpleViewPager()<UICollectionViewDataSource, UIScrollViewDelegate>
@property (nonatomic, strong) UICollectionView *mainView;
@property (nonatomic, strong) NSArray *dataList;
@end

@implementation MLNSimpleViewPager

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self mainView];
    }
    return self;
}


- (void)reloadWithDataList:(NSArray *)dataList
{
    _dataList = dataList;
    
    [self.mainView reloadData];
}

- (void)scrollToPage:(NSUInteger)index aniamted:(BOOL)animated {
    
    [self.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

#pragma mark - ScrollViewDelegate



#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MLNSimpleViewPagerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMLNSimpleViewPagerCell forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.mainTableView.tableType = @"follow";
    } else {
        cell.mainTableView.tableType = @"recommend";
    }
    [cell.mainTableView reloadTableWithDataList:self.dataList];
    
    return cell;
}

#pragma mark - Private method

- (UICollectionView *)mainView
{
    if (!_mainView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = self.bounds.size;
        UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        mainView.dataSource = self;
        mainView.backgroundColor = [UIColor clearColor];
        mainView.pagingEnabled = YES;
        mainView.showsHorizontalScrollIndicator = NO;
        mainView.showsVerticalScrollIndicator = NO;
        [mainView registerClass:[MLNSimpleViewPagerCell class] forCellWithReuseIdentifier:kMLNSimpleViewPagerCell];
        mainView.scrollsToTop = NO;
        mainView.bounces = NO;
        [self addSubview:mainView];
        mainView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            mainView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 10.0, *)) {
            mainView.prefetchingEnabled = NO;
        }
        _mainView = mainView;
        [self addSubview:self.mainView];
    }
    return _mainView;
}

@end
