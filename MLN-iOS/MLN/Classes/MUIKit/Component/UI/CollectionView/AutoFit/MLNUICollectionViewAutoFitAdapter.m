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
    return CGSizeZero;
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

LUAUI_EXPORT_BEGIN(MLNUICollectionViewAutoFitAdapter)
LUAUI_EXPORT_END(MLNUICollectionViewAutoFitAdapter, CollectionViewAutoFitAdapter, YES, "MLNUICollectionViewAdapter", NULL)

@end
