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

@implementation MLNUICollectionViewAutoFitAdapter

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
    MLNUICollectionViewCell *cell = [[MLNUICollectionViewCell alloc] init];
    [cell pushContentViewWithLuaCore:self.mlnui_luaCore];
    if (!cell.isInited) {
        MLNUIBlock *initCallback = [self initedCellCallbackByReuseId:reuseId];
        [initCallback addLuaTableArgument:[cell getLuaTable]];
        [initCallback callIfCan];
        [cell initCompleted];
    }
    MLNUIBlock *reuseCallback = [self fillCellDataCallbackByReuseId:reuseId];
    [reuseCallback addLuaTableArgument:[cell getLuaTable]];
    [reuseCallback addIntArgument:(int)indexPath.section+1];
    [reuseCallback addIntArgument:(int)indexPath.item+1];
    [reuseCallback callIfCan];
    CGSize size = [cell calculSizeWithMaxWidth:MLNUIUndefined maxHeight:MLNUIUndefined]; // 计算cell自适应大小
    // 3. update cache
    [self.cachesManager updateLayoutInfo:[NSValue valueWithCGSize:size] forIndexPath:indexPath];
    return size;
}

LUAUI_EXPORT_BEGIN(MLNUICollectionViewAutoFitAdapter)
LUAUI_EXPORT_END(MLNUICollectionViewAutoFitAdapter, CollectionViewAutoFitAdapter, YES, "MLNUICollectionViewAdapter", NULL)

@end
