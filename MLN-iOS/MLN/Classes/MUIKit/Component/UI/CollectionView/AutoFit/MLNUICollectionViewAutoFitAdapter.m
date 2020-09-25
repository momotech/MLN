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

@interface MLNUICollectionViewAutoFitAdapter ()<MLNUICollectionViewCellDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, MLNUICollectionViewAutoSizeCell *> *layoutCellCache;

@end

@implementation MLNUICollectionViewAutoFitAdapter

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
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
    CGSize size = [cell calculSizeWithMaxWidth:MLNUIUndefined maxHeight:MLNUIUndefined]; // 计算cell自适应大小
    [self.cachesManager updateLayoutInfo:[NSValue valueWithCGSize:size] forIndexPath:indexPath];
    return size;
}

#pragma mark - Override

- (Class)cellClass {
    return [MLNUICollectionViewAutoSizeCell class];
}

#pragma mark - MLNUICollectionViewCellDelegate

- (void)mlnuiCollectionViewCellShouldReload:(MLNUICollectionViewCell *)cell size:(CGSize)size {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (!indexPath) return;
    
    NSValue *cacheSize = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (cacheSize && CGSizeEqualToSize(cacheSize.CGSizeValue, size)) {
        return;
    }
    
    // 直接更新缓存中的 cell 大小，从而，
    // - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
    // 方法中可以直接命中缓存，否则需要再进行一次计算
    [self.cachesManager updateLayoutInfo:@(size) forIndexPath:indexPath];

    // cell 上内容变更引起重新测量布局后，需要重新调整 cell 大小. (即 invalidate collectionViewLayout)
    UICollectionViewLayoutInvalidationContext *invalidContext = [UICollectionViewLayoutInvalidationContext new];
    [invalidContext invalidateItemsAtIndexPaths:@[indexPath]];
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:invalidContext];
 }

#pragma mark - Private

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

LUAUI_EXPORT_BEGIN(MLNUICollectionViewAutoFitAdapter)
LUAUI_EXPORT_END(MLNUICollectionViewAutoFitAdapter, CollectionViewAutoFitAdapter, YES, "MLNUICollectionViewAdapter", NULL)

@end
