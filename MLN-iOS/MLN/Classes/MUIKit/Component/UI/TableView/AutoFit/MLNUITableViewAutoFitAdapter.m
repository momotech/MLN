//
//  MLNUITableViewAutoFitAdapter.m
//
//
//  Created by MoMo on 2018/11/9.
//

#import "MLNUITableViewAutoFitAdapter.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUITableView.h"
#import "MLNUITableViewCell.h"
#import "MLNUIBlock.h"
#import "NSDictionary+MLNUISafety.h"

#if DEBUG && 0
#define TICK()   CFAbsoluteTime lcoal__start = CFAbsoluteTimeGetCurrent();\
CFAbsoluteTime lcoal__start2 = lcoal__start;\
printf("\n");
#define TOCK(...) printf(">>>TOCK "); printf(__VA_ARGS__); printf(" cost %.2f ms \n",(CFAbsoluteTimeGetCurrent() - lcoal__start) * 1000); \
lcoal__start = CFAbsoluteTimeGetCurrent()

#define TOCKALL(...) printf(">>>TOCK "); printf(__VA_ARGS__); printf(" cost %.2f ms \n",(CFAbsoluteTimeGetCurrent() - lcoal__start2) * 1000);
#else
#define TICK()
#define TOCK(...)
#define TOCKALL(...)
#endif

@interface MLNUITableViewAutoFitAdapter ()<MLNUITableViewCellDelegate, MLNUITableViewCellSettingProtocol>

@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUITableViewCell *> *calculCells;

@end

@implementation MLNUITableViewAutoFitAdapter

- (CGSize)cellMaxSize {
    return CGSizeMake(self.targetTableView.frame.size.width, MLNUIUndefined);
}

- (void)prepareToUseCell:(__kindof MLNUITableViewCell *)cell {
    [cell createLuaTableAsCellNameForLuaIfNeed:self.mlnui_luaCore];
    [cell createLayoutNodeIfNeedWithFitSize:self.cellMaxSize /*cell.luaContentView宽度和cell保持一致，高度自适应*/
                                    maxSize:self.cellMaxSize];
}

#pragma mark - Override

- (Class)tableViewCellClass {
    return [MLNUITableViewAutoHeightCell class];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TICK();
    NSString *reuseId = [self reuseIdAt:indexPath];
    MLNUIBlock *initCallback = [self initedCellCallbackByReuseId:reuseId];
    MLNUIKitLuaAssert(initCallback, @"It must not be nil callback of cell init!");
    if (!initCallback) {
        [self.targetTableView registerClass:self.tableViewCellClass forCellReuseIdentifier:reuseId];
    }
    MLNUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    cell.delegate = self;
    TOCK("befor init %zd",indexPath.row);
    [self prepareToUseCell:cell];
    
    if (!cell.isInited) {
        [initCallback addLuaTableArgument:[cell getLuaTable]];
        [initCallback callIfCan];
        [cell initCompleted];
        TOCK("init ");
    }
    
    MLNUIBlock *reuseCallback = [self fillCellDataCallbackByReuseId:reuseId];
    if (reuseCallback) {
        [reuseCallback addLuaTableArgument:[cell getLuaTable]];
        [reuseCallback addIntArgument:(int)indexPath.section+1];
        [reuseCallback addIntArgument:(int)indexPath.row+1];
        [reuseCallback callIfCan];
        TOCK("fill cell data");
    }

    __block CGFloat height = CGFloatValueFromNumber([self.cachesManager layoutInfoWithIndexPath:indexPath]);
    if (height <= 0) {
        height = [cell caculateCellSizeWithFitSize:self.cellMaxSize maxSize:self.cellMaxSize apply:YES].height;
        if (![self.cachesManager layoutInfoWithIndexPath:indexPath]) {
            [self.cachesManager updateLayoutInfo:@(height) forIndexPath:indexPath];
        }
        TOCK("caculate height");
    }
    TOCKALL("cell for row %zd",indexPath.row);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = CGFloatValueFromNumber([self.cachesManager layoutInfoWithIndexPath:indexPath]);
    if (height > 0) {
        return height;
    }
    NSLog(@"===ArgoUI=== height for row estimated height: %0.2f", tableView.estimatedRowHeight);
    return tableView.estimatedRowHeight;
}

//- (void)updateCellWidthIfNeed:(MLNUITableViewCell *)cell tableViewWidth:(CGFloat)tableViewWidth
//{
//    if (cell.frame.size.width != tableViewWidth) {
//        CGRect frame = cell.frame;
//        frame.size.width = tableViewWidth;
//        cell.frame = frame;
//    }
//}

- (void)luaui_heightForRowCallback:(MLNUIBlock *)callback
{
     MLNUIKitLuaAssert(NO, @"Not fount method [AutoFitAdapter heightForCell]!");
}

- (MLNUITableViewCell *)tableView:(UITableView *)tableView dequeueCalculCellForIdentifier:(NSString *)identifier
{
    MLNUITableViewCell *cell = [self.calculCells objectForKey:identifier];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            [tableView registerClass:self.tableViewCellClass forCellReuseIdentifier:identifier];
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            cell.delegate = self;
        }
        [self.calculCells mlnui_setObject:cell forKey:identifier];
    }
    return cell;
}

#pragma mark - MLNUITableViewCellDelegate

- (void)mlnuiTableViewCellShouldReload:(MLNUITableViewCell *)cell size:(CGSize)size {
    NSIndexPath *indexPath = [self.targetTableView indexPathForCell:cell];
    if (!indexPath) return;
    
    NSNumber *cacheHeight = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (cacheHeight && ABS(cacheHeight.floatValue - size.height) < 0.001) {
        return;
    }
    
    // 直接更新缓存中的 cell 大小，从而，
    // - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
    // 方法中可以直接命中缓存，否则需要再进行一次计算
    [self.cachesManager updateLayoutInfo:@(size.height) forIndexPath:indexPath];

    // TODO: cell 上内容变更引起重新测量布局后，需要重新调整 cell 大小.
}

#pragma mark - Getter
- (NSMutableDictionary<NSString *,MLNUITableViewCell *> *)calculCells
{
    if (!_calculCells) {
        _calculCells = [NSMutableDictionary dictionary];
    }
    return _calculCells;
}

LUAUI_EXPORT_BEGIN(MLNUITableViewAutoFitAdapter)
LUAUI_EXPORT_END(MLNUITableViewAutoFitAdapter, TableViewAutoFitAdapter, YES, "MLNUITableViewAdapter", NULL)

@end
