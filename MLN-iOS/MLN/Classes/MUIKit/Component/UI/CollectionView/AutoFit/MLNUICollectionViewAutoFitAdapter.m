//
//  MLNUICollectionViewAutoFitAdapter.m
//
//
//  Created by MoMo on 2019/2/19.
//

#import "MLNUICollectionViewAutoFitAdapter.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUICollectionViewCell.h"
#import "MLNUICollectionView.h"
#import "UIScrollView+MLNUIKit.h"
#import "MLNUIBlock.h"
#import "MLNUIKitHeader.h"

CGSize MLNUICollectionViewAutoFitCellEstimateSize = (CGSize){60, 60};

@interface MLNUICollectionViewAutoFitAdapter ()<MLNUICollectionViewCellDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, MLNUICollectionViewAutoSizeCell *> *layoutCellCache;

@end

@implementation MLNUICollectionViewAutoFitAdapter

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSValue *sizeValue = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (sizeValue) {
        CGSize size = [sizeValue CGSizeValue];
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            return size;
        }
    }
    return MLNUICollectionViewAutoFitCellEstimateSize;
    
    /**
    // first get cache
    NSValue *sizeValue = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (sizeValue) {
        CGSize size = [sizeValue CGSizeValue];
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            return size;
        }
    }
    
    // caculate if no cache
    NSString *reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    [self registerCellClassIfNeed:collectionView reuseId:reuseId];
    
    // 该 cell 仅仅是用来计算布局使用，不会显示到屏幕上
    MLNUICollectionViewAutoSizeCell *cell = [self layoutCellWithIndexPath:indexPath];
    cell.delegate = self;
    MLNUILuaTable *luaCell = [cell createLuaTableAsCellNameForLuaIfNeed:self.mlnui_luaCore];
    
    MLNUIBlock *initCallback = [self initedCellCallbackByReuseId:reuseId];
    [initCallback addLuaTableArgument:luaCell];
    [initCallback callIfCan];
    
    MLNUIBlock *reuseCallback = [self fillCellDataCallbackByReuseId:reuseId];
    [reuseCallback addLuaTableArgument:luaCell];
    [reuseCallback addIntArgument:(int)indexPath.section+1];
    [reuseCallback addIntArgument:(int)indexPath.item+1];
    [reuseCallback callIfCan];
    
    // update cache
    CGSize size = [cell caculateCellSizeWithMaxSize:self.cellMaxSize apply:YES];
    [self.cachesManager updateLayoutInfo:[NSValue valueWithCGSize:size] forIndexPath:indexPath];
    return size;
     */
}

#pragma mark - Override

- (Class)collectionViewCellClass {
    return [MLNUICollectionViewAutoSizeCell class];
}

- (CGSize)fitSizeForCell:(MLNUICollectionViewCell *)cell {
    return CGSizeZero; // 自适应场景：cell.luaContentView大小自适应
}

#pragma mark - MLNUICollectionViewCellDelegate

- (void)mlnuiCollectionViewCellShouldReload:(MLNUICollectionViewCell *)cell size:(CGSize)size {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (!indexPath) return;
    
    NSValue *cacheSize = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (cacheSize && CGSizeEqualToSize(cacheSize.CGSizeValue, size)) {
        return;
    }
    [self flushCacheForSize:size indexPath:indexPath];
   
    // cell 上内容变更引起重新测量布局后，需要重新调整 cell 大小. (即 invalidate collectionViewLayout)
    UICollectionViewFlowLayoutInvalidationContext *invalidContext = [UICollectionViewFlowLayoutInvalidationContext new];
    [invalidContext invalidateItemsAtIndexPaths:@[indexPath]];
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:invalidContext];
 }

- (CGSize)mlnuiCollectionViewAutoFitSizeForCell:(MLNUICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    if (!indexPath) return CGSizeZero;
    NSValue *cacheSize = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (!cacheSize) {
        CGSize size = [cell caculateCellSizeWithMaxSize:self.cellMaxSize apply:YES];
        [self flushCacheForSize:size indexPath:indexPath];
        return size;
    }
    return cacheSize.CGSizeValue;
}

#pragma mark - Private

- (void)flushCacheForSize:(CGSize)size indexPath:(NSIndexPath *)indexPath {
    // 更新 cell size 缓存
    [self.cachesManager updateLayoutInfo:@(size) forIndexPath:indexPath];
    
    // 针对带有估算高度的 cell 的情况，需要更新真实高度
//    MLNUICollectionViewGridLayout *layout = (MLNUICollectionViewGridLayout *)self.collectionView.collectionViewLayout;
//    if ([layout isKindOfClass:[MLNUICollectionViewGridLayout class]]) {
//        [layout updateRealSize:size forIndexPath:indexPath];
//    } else {
//        NSAssert(false, @"The collectionView layout should be kind of MLNUICollectionViewGridLayout class.");
//    }
}

/**
- (NSMutableDictionary<NSIndexPath *,MLNUICollectionViewAutoSizeCell *> *)layoutCellCache {
    if (!_layoutCellCache) {
        _layoutCellCache = [NSMutableDictionary dictionary];
    }
    return _layoutCellCache;
}

- (MLNUICollectionViewAutoSizeCell *)layoutCellWithIndexPath:(NSIndexPath *)indexPath {
    MLNUIKitLuaAssert(indexPath, @"Expect a valid indexPath: (null).");
    if (!indexPath) return nil;
    MLNUICollectionViewAutoSizeCell *cell = self.layoutCellCache[indexPath];
    if (!cell) {
        cell = [[MLNUICollectionViewAutoSizeCell alloc] init];
        self.layoutCellCache[indexPath] = cell;
    }
    return cell;
}
*/

LUAUI_EXPORT_BEGIN(MLNUICollectionViewAutoFitAdapter)
LUAUI_EXPORT_END(MLNUICollectionViewAutoFitAdapter, CollectionViewAutoFitAdapter, YES, "MLNUICollectionViewAdapter", NULL)

@end
