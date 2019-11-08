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
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    self.beginIndex = ceil(scrollView.contentOffset.x / scrollView.frame.size.width);
//    _scrollToIndex = -1;
//    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
//        [_segmentViewHandler scrollViewWillBeginDragging:scrollView];
//    }
//    if ([_viewPagerScrollHandler respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
//        [_viewPagerScrollHandler scrollViewWillBeginDragging:scrollView];
//    }
//    self.lastContentOffsetX = scrollView.contentOffset.x;
//    if (!self.autoScroll) return;
//    [self invalidateTimer];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
//        [_segmentViewHandler scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//    }
//    if ([_viewPagerScrollHandler respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
//        [_viewPagerScrollHandler scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//    }
//    if (!self.autoScroll) return;
//    [self setupTimer];
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewDidScroll:)]) {
//        [_segmentViewHandler scrollViewDidScroll:scrollView];
//    }
//    if ([_viewPagerScrollHandler respondsToSelector:@selector(scrollViewDidScroll:)]) {
//        [_viewPagerScrollHandler scrollViewDidScroll:scrollView];
//    }
//    if (!self.totalItemsCount) return; // 解决清除timer时偶尔会出现的问题
//    int itemIndex = [self currentIndex];
//    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
//    UIPageControl *pageControl = (UIPageControl *)_pageControl;
//    pageControl.currentPage = indexOnPageControl;
//    if (_scrollToIndex == itemIndex && (int)floor(scrollView.contentOffset.x) % (int)floor(scrollView.frame.size.width ?: 1) == 0) {
//        [self didChangedPage];
//        _scrollToIndex = -1;
//    }
//}
//
//
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    NSInteger currentPage =  [self correctCurrentIndex];
//    if (currentPage != self.beginIndex) {
//        [self didChangedPage];
//    }
//    if ([scrollView isKindOfClass:[UICollectionView class]]) {
//        if (currentPage < [self.adapter collectionView:(UICollectionView*)scrollView numberOfItemsInSection:0] - 1 && currentPage != self.beginIndex && _aheadLoad ) {
//            [self aheadLoadPage:currentPage + 1];
//            [self aheadLoadPage:currentPage - 1];
//        }
//    }
//    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
//        [_segmentViewHandler scrollViewDidEndDecelerating:scrollView];
//    }
//    if ([_viewPagerScrollHandler respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
//        [_viewPagerScrollHandler scrollViewDidEndDecelerating:scrollView];
//    }
//    [self scrollToCorrectPage];
//}
//
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//    if ([_segmentViewHandler respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
//        [_segmentViewHandler scrollViewDidEndScrollingAnimation:scrollView];
//    }
//    if ([_viewPagerScrollHandler respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
//        [_viewPagerScrollHandler scrollViewDidEndScrollingAnimation:scrollView];
//    }
//    if (!self.totalItemsCount) return; // 解决清除timer时偶尔会出现的问题
//    int itemIndex = [self currentIndex];
//    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex]+1;
//    [self.didEndDeceleratingBlock addIntArgument:indexOnPageControl];
//    [self.didEndDeceleratingBlock callIfCan];
//    
//    [self scrollToCorrectPage];
//}
//
//- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
//{
//    if (self.cellWillAppearCallback) {
//        MLNKitLuaAssert([cell isKindOfClass:[MLNCollectionViewCell class]], @"Unkown type of cell");
//        MLNCollectionViewCell *cell_t = (MLNCollectionViewCell *)cell;
//        [self.cellWillAppearCallback addLuaTableArgument:[cell_t getLuaTable]];
//        [self.cellWillAppearCallback addIntArgument:(int)indexPath.item+1];
//        [self.cellWillAppearCallback callIfCan];
//    }
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.cellDidDisappearCallback) {
//        MLNKitLuaAssert([cell isKindOfClass:[MLNCollectionViewCell class]], @"Unknow type of cell!");
//        MLNCollectionViewCell *cell_t = (MLNCollectionViewCell *)cell;
//        [self.cellDidDisappearCallback addLuaTableArgument:[cell_t getLuaTable]];
//        [self.cellDidDisappearCallback addIntArgument:(int)indexPath.item+1];
//        [self.cellDidDisappearCallback callIfCan];
//    }
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.cellClickedCallback) {
//        int curItem = self.mainView.contentOffset.x/self.mainView.frame.size.width;
//        int curIdx = [self pageControlIndexWithCurrentCellIndex:curItem] + 1;
//        [self.cellClickedCallback addIntArgument:curIdx];
//        [self.cellClickedCallback callIfCan];
//    }
//}
//
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    NSInteger itemIndex = targetContentOffset->x/_mainView.frame.size.width;
//    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex]+1;
//    [self.didEndDeceleratingBlock addIntArgument:indexOnPageControl];
//    [self.didEndDeceleratingBlock callIfCan];
//}



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
