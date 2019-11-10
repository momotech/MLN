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

#define kMLNSimpleViewPagerCell  @"kMLNSimpleViewPagerCell"

@interface MLNSimpleViewPager()<UICollectionViewDataSource, UIScrollViewDelegate>
@property (nonatomic, strong) UICollectionView *mainView;
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
        UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        mainView.dataSource = self;
        mainView.backgroundColor = [UIColor clearColor];
        mainView.pagingEnabled = YES;
        mainView.showsHorizontalScrollIndicator = NO;
        mainView.showsVerticalScrollIndicator = NO;
        [mainView registerClass:[MLNSimpleViewPagerCell class] forCellWithReuseIdentifier:kMLNSimpleViewPagerCell];
        mainView.scrollsToTop = NO;
        mainView.bounces = NO;
        mainView.delegate = self;
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
