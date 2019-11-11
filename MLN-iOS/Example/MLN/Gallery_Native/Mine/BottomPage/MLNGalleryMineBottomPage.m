//
//  MLNGalleryMineBottomPage.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import "MLNGalleryMineBottomPage.h"
#import "MLNGalleryMinePageCellBaseModel.h"
#import "MLNGalleryMineBottomPageBaseCell.h"

#define kMLNMinePageIdentifier @"kMLNMinePageIdentifier"

@interface MLNGalleryMineBottomPage()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *mainView;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, assign) NSInteger missionIndex;

@end


@implementation MLNGalleryMineBottomPage

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self mainView];
    }
    return self;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (_bottomModels.count > 0) {
        [self.mainView reloadData];
    }
}

- (void)setBottomModels:(NSArray<MLNGalleryMinePageCellBaseModel *> *)bottomModels
{
    _bottomModels = bottomModels;
    for (MLNGalleryMinePageCellBaseModel *baseModel in bottomModels) {
        [self.mainView registerClass:baseModel.cellClass forCellWithReuseIdentifier:baseModel.identifier];
    }
    if (self.superview != nil) {
        [self.mainView reloadData];
    }
}

- (void)scrollToPage:(NSInteger)index
{
    if (index < self.bottomModels.count) {
        [self.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
    
}

- (UICollectionView *)mainView
{
    if (!_mainView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = self.bounds.size;
        _flowLayout = flowLayout;
        _mainView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _mainView.delegate = self;
        _mainView.dataSource = self;
        _mainView.pagingEnabled = YES;
        _mainView.backgroundColor = [UIColor clearColor];
        [self addSubview:_mainView];
    }
    return _mainView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.bottomModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MLNGalleryMinePageCellBaseModel *baseModel = nil;
    if (indexPath.row < self.bottomModels.count) {
        baseModel = [self.bottomModels objectAtIndex:indexPath.row];
    } else {
        baseModel = [MLNGalleryMinePageCellBaseModel new];
    }
    MLNGalleryMineBottomPageBaseCell *cell = (MLNGalleryMineBottomPageBaseCell*)[collectionView dequeueReusableCellWithReuseIdentifier:baseModel.identifier forIndexPath:indexPath];
    cell.cellModel = baseModel;
    return cell;
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

@end
