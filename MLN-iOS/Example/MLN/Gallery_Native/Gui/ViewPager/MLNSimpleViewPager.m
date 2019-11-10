//
//  MLNSimpleViewPager.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/6.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNSimpleViewPager.h"
#import "MLNSimpleViewPagerCell.h"
#import "MLNHomeTableView.h"
#import <MJRefresh.h>

#define kMLNSimpleViewPagerCell  @"kMLNSimpleViewPagerCell"

@interface MLNSimpleViewPager()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong, readwrite) UICollectionView *mainView;
@property (nonatomic, strong) NSArray *dataList;

@property (nonatomic, copy) RefreshBlock refreshBlock;
@property (nonatomic, copy) LoadingBlock loadingBlock;
@property (nonatomic, copy) SearchBlock searchBlock;
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

- (void)setRefreshBlock:(RefreshBlock)refreshBlock
{
    _refreshBlock = refreshBlock;
}

- (void)setLoadingBlock:(LoadingBlock)loadingBlock
{
    _loadingBlock = loadingBlock;
}

- (void)setSearchBlock:(SearchBlock)searchBlock
{
    _searchBlock = searchBlock;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_segmentViewHandler scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_segmentViewHandler scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_segmentViewHandler scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_segmentViewHandler scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [_segmentViewHandler scrollViewDidEndScrollingAnimation:scrollView];
    }
}

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
    [cell.mainTableView setRefreshBlock:_refreshBlock];
    [cell.mainTableView setLoadingBlock:_loadingBlock];
    [cell.mainTableView setSearchBlock:_searchBlock];
    
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
        _mainView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _mainView.backgroundColor = [UIColor whiteColor];
        _mainView.pagingEnabled = YES;
        _mainView.scrollsToTop = NO;
        _mainView.bounces = NO;
        _mainView.showsHorizontalScrollIndicator = NO;
        _mainView.showsVerticalScrollIndicator = NO;
        _mainView.dataSource = self;
        _mainView.delegate = self;
        [_mainView registerClass:[MLNSimpleViewPagerCell class] forCellWithReuseIdentifier:kMLNSimpleViewPagerCell];
        if (@available(iOS 11.0, *)) {
            _mainView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//            _mainView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
        }
        if (@available(iOS 10.0, *)) {
            _mainView.prefetchingEnabled = NO;
        }
        [self addSubview:_mainView];
    }
    return _mainView;
}

@end
