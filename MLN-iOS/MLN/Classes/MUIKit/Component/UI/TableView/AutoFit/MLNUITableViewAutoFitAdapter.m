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

@interface MLNUITableViewAutoFitAdapter ()<MLNUITableViewCellDelegate, MLNUITableViewCellSettingProtocol>

@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUITableViewCell *> *calculCells;

@end

@implementation MLNUITableViewAutoFitAdapter

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = CGFloatValueFromNumber([self.cachesManager layoutInfoWithIndexPath:indexPath]);
    if (height > 0) {
        return height;
    }
    CGFloat tableViewWidth = tableView.frame.size.width;
    NSString *reuseId = [self reuseIdAt:indexPath];
    MLNUITableViewCell *cell = [self tableView:tableView dequeueCalculCellForIdentifier:reuseId];
    [self updateCellWidthIfNeed:cell tableViewWidth:tableViewWidth];
    [cell pushContentViewWithLuaCore:self.mlnui_luaCore];
    if (!cell.isInited) {
        MLNUIBlock *initCallback = [self initedCellCallbackByReuseId:reuseId];
        MLNUIKitLuaAssert(initCallback, @"It must not be nil callback of cell init!");
        [initCallback addLuaTableArgument:[cell getLuaTable]];
        [initCallback callIfCan];
        [cell initCompleted];
    }
    MLNUIBlock *reuseCallback = [self fillCellDataCallbackByReuseId:reuseId];
    MLNUIKitLuaAssert(reuseCallback, @"It must not be nil callback of cell reuse!");
    [reuseCallback addLuaTableArgument:[cell getLuaTable]];
    [reuseCallback addIntArgument:(int)indexPath.section+1];
    [reuseCallback addIntArgument:(int)indexPath.row+1];
    [reuseCallback callIfCan];
    height = [cell calculHeightWithWidth:tableViewWidth maxHeight:MLNUIUndefined];
    [self.cachesManager updateLayoutInfo:@(height) forIndexPath:indexPath];
    return height;
}

- (void)updateCellWidthIfNeed:(MLNUITableViewCell *)cell tableViewWidth:(CGFloat)tableViewWidth
{
    if (cell.frame.size.width != tableViewWidth) {
        CGRect frame = cell.frame;
        frame.size.width = tableViewWidth;
        cell.frame = frame;
    }
}

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
            [tableView registerClass:[MLNUITableViewCell class] forCellReuseIdentifier:identifier];
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            cell.delegate = self;
        }
        [self.calculCells mlnui_setObject:cell forKey:identifier];
    }
    return cell;
}

#pragma mark - MLNUITableViewCellDelegate

- (void)mlnuiTableViewCellShouldReload:(MLNUITableViewCell *)cell {
    if (CGPointEqualToPoint(self.targetTableView.contentOffset, CGPointZero)) { // 主要处理首次加载页面cell显示不正确的问题
        SEL selector = @selector(reloadCellInIdleStatus);
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];
        [self performSelector:selector withObject:nil afterDelay:0.2]; // default runloop mode
    }
}

- (void)reloadCellInIdleStatus {
    [self.cachesManager invalidateAllCaches];
    [self.mlnuiTableView reloadDataInIdleStatus];
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
