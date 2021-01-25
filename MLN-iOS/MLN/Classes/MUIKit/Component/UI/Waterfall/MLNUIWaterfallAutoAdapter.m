//
//  MLNUIWaterfallAutoAdapter.m
//  ArgoUI
//
//  Created by MOMO on 2020/9/28.
//

#import "MLNUIWaterfallAutoAdapter.h"
#import "MLNUICollectionViewCell.h"
#import "MLNUIKitHeader.h"
#import "MLNUIInternalWaterfallView.h"
#import "MLNUIWaterfallHeaderView.h"

FOUNDATION_EXTERN CGSize MLNUICollectionViewAutoFitCellEstimateSize;

@interface MLNUIWaterfallAutoAdapter ()<MLNUICollectionViewCellDelegate, MLNUIWaterfallHeaderViewDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, NSValue *> *headerViewSizeCache;

@end

@implementation MLNUIWaterfallAutoAdapter

#pragma mark - Override

- (Class)headerViewClass {
    return [MLNUIWaterfallAutoFitHeaderView class];
}

- (Class)collectionViewCellClass {
    return [MLNUICollectionViewAutoSizeCell class];
}

- (CGSize)fitSizeForCell:(MLNUICollectionViewCell *)cell {
    return CGSizeMake(cell.frame.size.width, MLNUIUndefined); // 自适应场景：cell.luaContentView高度自适应
}

- (CGSize)headerViewFitSize:(UICollectionReusableView *)headerView {
    return CGSizeMake(headerView.frame.size.width, MLNUIUndefined); // 自适应场景：headerView.luaContentView高度自适应
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSValue *sizeValue = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (sizeValue) {
        CGSize size = [sizeValue CGSizeValue];
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            return size.height;
        }
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section != 0) { // WaterfallView 限制只有一个headerView
        return CGSizeZero;
    }
    NSValue *value = [self.headerViewSizeCache objectForKey:[NSIndexPath indexPathForItem:0 inSection:section]];
    if (value) {
        return [value CGSizeValue];
    }
    return CGSizeZero;
}

#pragma mark - MLNUICollectionViewCellDelegate

- (void)mlnuiCollectionViewCellShouldReload:(MLNUICollectionViewCell *)cell size:(CGSize)size {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (!indexPath) return;
    
    NSValue *cacheSize = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (cacheSize && CGSizeEqualToSize(cacheSize.CGSizeValue, size)) {
        return;
    }
    [self.cachesManager updateLayoutInfo:@(size) forIndexPath:indexPath];

    // cell 上内容变更引起重新测量布局后，需要重新调整 cell 大小. (即 invalidate collectionViewLayout)
    [self.collectionView.collectionViewLayout invalidateLayout];
 }

- (CGSize)mlnuiCollectionViewAutoFitSizeForCell:(MLNUICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    if (!indexPath) return CGSizeZero;
    NSValue *cacheSize = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (!cacheSize) {
        CGSize size = [cell caculateCellSizeWithMaxSize:self.cellMaxSize apply:YES];
        [self.cachesManager updateLayoutInfo:@(size) forIndexPath:indexPath];
        return size;
    }
    return cacheSize.CGSizeValue;
}

#pragma mark - MLNUIWaterfallHeaderViewDelegate

- (void)mlnuiWaterfallViewHeaderViewShouldReload:(MLNUIWaterfallHeaderView *)headerView size:(CGSize)size {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    NSValue *cacheSize = [self.headerViewSizeCache objectForKey:indexPath];
    if (cacheSize && CGSizeEqualToSize(cacheSize.CGSizeValue, size)) {
        return;
    }
    [self.headerViewSizeCache setObject:@(size) forKey:indexPath];

    // headerView 上内容变更引起重新测量布局后，需要重新调整 headerView 大小. (即 invalidate collectionViewLayout)
    [self.collectionView.collectionViewLayout invalidateLayout];
 }

- (CGSize)mlnuiWaterfallAutoFitSizeForHeaderView:(MLNUIWaterfallHeaderView *)headerView indexPath:(NSIndexPath *)indexPath {
    if (!indexPath) return CGSizeZero;
    NSValue *cacheSize = [self.headerViewSizeCache objectForKey:indexPath];
    if (!cacheSize) {
        CGSize size = [headerView caculateCellSizeWithMaxSize:[self headerViewMaxSize:headerView] apply:YES];
        [self.headerViewSizeCache setObject:@(size) forKey:indexPath];
        return size;
    }
    return cacheSize.CGSizeValue;
}

#pragma mark - Private

- (NSMutableDictionary<NSIndexPath *,NSValue *> *)headerViewSizeCache {
    if (!_headerViewSizeCache) {
        _headerViewSizeCache = [NSMutableDictionary dictionary];
    }
    return _headerViewSizeCache;
}

#pragma mark - Export Lua

LUAUI_EXPORT_BEGIN(MLNUIWaterfallAutoAdapter)
LUAUI_EXPORT_END(MLNUIWaterfallAutoAdapter, WaterfallAutoFitAdapter, YES, "MLNUIWaterfallAdapter", NULL)

@end
