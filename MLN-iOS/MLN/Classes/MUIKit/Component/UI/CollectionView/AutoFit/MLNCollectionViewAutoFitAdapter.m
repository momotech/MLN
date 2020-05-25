//
//  MLNCollectionViewAutoFitAdapter.m
//
//
//  Created by MoMo on 2019/2/19.
//

#import "MLNCollectionViewAutoFitAdapter.h"
#import "MLNViewExporterMacro.h"
#import "MLNCollectionViewCell.h"
#import "MLNCollectionView.h"
#import "UIScrollView+MLNKit.h"
#import "MLNBlock.h"

@implementation MLNCollectionViewAutoFitAdapter

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 1. cache
    NSValue *sizeValue = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (sizeValue) {
        CGSize size = [sizeValue CGSizeValue];
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            return size;
        }
    }
    // 2. calculate size
    NSString *reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    [self registerCellClassIfNeed:collectionView reuseId:reuseId];
    CGFloat width = collectionView.frame.size.width;
    CGFloat height = collectionView.frame.size.height;
    CGFloat maxWidth = width;
    CGFloat maxHeight = CGFLOAT_MAX;
    if (collectionView.mln_horizontal) {
        maxWidth = CGFLOAT_MAX;
        maxHeight = height;
    }
    MLNCollectionViewCell *cell = [[MLNCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [cell pushContentViewWithLuaCore:self.mln_luaCore];
    if (!cell.isInited) {
        MLNBlock *initCallback = [self initedCellCallbackByReuseId:reuseId];
        [initCallback addLuaTableArgument:[cell getLuaTable]];
        [initCallback callIfCan];
        [cell initCompleted];
    }
    MLNBlock *reuseCallback = [self fillCellDataCallbackByReuseId:reuseId];
    [reuseCallback addLuaTableArgument:[cell getLuaTable]];
    [reuseCallback addIntArgument:(int)indexPath.section+1];
    [reuseCallback addIntArgument:(int)indexPath.item+1];
    [reuseCallback callIfCan];
    CGSize size = [cell calculSizeWithMaxWidth:maxWidth maxHeight:maxHeight];
    // 3. update cache
    [self.cachesManager updateLayoutInfo:[NSValue valueWithCGSize:size] forIndexPath:indexPath];
    return size;
}

LUA_EXPORT_BEGIN(MLNCollectionViewAutoFitAdapter)
LUA_EXPORT_END(MLNCollectionViewAutoFitAdapter, CollectionViewAutoFitAdapter, YES, "MLNCollectionViewAdapter", NULL)

@end
