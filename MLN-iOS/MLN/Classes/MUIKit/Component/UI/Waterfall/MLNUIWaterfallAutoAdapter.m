//
//  MLNUIWaterfallAutoAdapter.m
//  ArgoUI
//
//  Created by xindong on 2020/9/28.
//

#import "MLNUIWaterfallAutoAdapter.h"
#import "MLNUICollectionViewCell.h"
#import "MLNUIKitHeader.h"
#import "MLNUIInternalWaterfallView.h"
#import "MLNUIWaterfallHeaderView.h"

#define MLNUI_INFINITE_VALUE 0

@interface MLNUIWaterfallAutoAdapter ()

@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, MLNUICollectionViewAutoSizeCell *> *layoutCellCache;

@end

@implementation MLNUIWaterfallAutoAdapter

#pragma mark - Override

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // first get cache
    NSValue *sizeValue = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (sizeValue) {
        CGSize size = [sizeValue CGSizeValue];
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            return size.height;
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
    return size.height;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section != 0) { // WaterfallView 限制只有一个headerView
        return CGSizeMake(0, 0);
    }
    
    UIView *headerView = [MLNUIInternalWaterfallView headerViewInWaterfall:collectionView];
    if (!headerView) { // headerView 不存在，使用header新接口initedHeader、fillHeaderData、heightForHeader
        BOOL isHeaderValid = [self headerIsValidWithWaterfallView:collectionView];
        if (section == 0 && isHeaderValid) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            [collectionView registerClass:[MLNUIWaterfallHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMLNUIWaterfallHeaderViewReuseID];
            MLNUIWaterfallHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMLNUIWaterfallHeaderViewReuseID forIndexPath:indexPath];
            [header createLuaTableAsCellNameForLuaIfNeed:self.mlnui_luaCore];

            [self.initedHeaderCallback addLuaTableArgument:[header getLuaTable]];
            [self.initedHeaderCallback addIntArgument:(int)indexPath.section+1];
            [self.initedHeaderCallback addIntArgument:(int)indexPath.row+1];
            [self.initedHeaderCallback callIfCan];
         
            [self.reuseHeaderCallback addLuaTableArgument:[header getLuaTable]];
            [self.reuseHeaderCallback addIntArgument:(int)indexPath.section+1];
            [self.reuseHeaderCallback addIntArgument:(int)indexPath.row+1];
            [self.reuseHeaderCallback callIfCan];
            
            CGSize size = [header caculateCellSizeWithMaxSize:CGSizeMake(collectionView.frame.size.width, MLNUI_INFINITE_VALUE) apply:NO];
            return CGSizeMake(0, size.height);
        }
        return CGSizeZero;
    }
    
    CGSize size = [headerView.mlnui_layoutNode calculateLayoutWithSize:CGSizeMake(collectionView.frame.size.width, MLNUI_INFINITE_VALUE)];
    return CGSizeMake(0, size.height);
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

#pragma mark - Export Lua

LUAUI_EXPORT_BEGIN(MLNUIWaterfallAutoAdapter)
LUAUI_EXPORT_END(MLNUIWaterfallAutoAdapter, WaterfallAutoAdapter, YES, "MLNUIWaterfallAdapter", NULL)

@end
