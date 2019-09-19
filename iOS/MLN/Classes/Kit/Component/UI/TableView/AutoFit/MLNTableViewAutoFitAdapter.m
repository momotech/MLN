//
//  MLNTableViewAutoFitAdapter.m
//
//
//  Created by MoMo on 2018/11/9.
//

#import "MLNTableViewAutoFitAdapter.h"
#import "MLNKitHeader.h"
#import "MLNViewExporterMacro.h"
#import "MLNTableView.h"
#import "MLNTableViewCell.h"
#import "MLNBlock.h"
#import "NSDictionary+MLNSafety.h"

@interface MLNTableViewAutoFitAdapter ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNTableViewCell *> *calculCells;

@end

@implementation MLNTableViewAutoFitAdapter

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = CGFloatValueFromNumber([self.cachesManager layoutInfoWithIndexPath:indexPath]);
    if (height > 0) {
        return height;
    }
    CGFloat tableViewWidth = tableView.frame.size.width;
    NSString *reuseId = [self reuseIdAt:indexPath];
    MLNTableViewCell *cell = [self tableView:tableView dequeueCalculCellForIdentifier:reuseId];
    [self updateCellWidthIfNeed:cell tableViewWidth:tableViewWidth];
    [cell pushContentViewWithLuaCore:self.mln_luaCore];
    if (!cell.isInited) {
        MLNBlock *initCallback = [self initedCellCallbackByReuseId:reuseId];
        MLNKitLuaAssert(initCallback, @"It must not be nil callback of cell init!");
        [initCallback addLuaTableArgument:[cell getLuaTable]];
        [initCallback callIfCan];
        [cell initCompleted];
    }
    MLNBlock *reuseCallback = [self fillCellDataCallbackByReuseId:reuseId];
    MLNKitLuaAssert(reuseCallback, @"It must not be nil callback of cell reuse!");
    [reuseCallback addLuaTableArgument:[cell getLuaTable]];
    [reuseCallback addIntArgument:(int)indexPath.section+1];
    [reuseCallback addIntArgument:(int)indexPath.row+1];
    [reuseCallback callIfCan];
    height = [cell calculHeightWithWidth:tableViewWidth maxHeight:CGFLOAT_MAX];
    [self.cachesManager updateLayoutInfo:@(height) forIndexPath:indexPath];
    return height;
}

- (void)updateCellWidthIfNeed:(MLNTableViewCell *)cell tableViewWidth:(CGFloat)tableViewWidth
{
    if (cell.frame.size.width != tableViewWidth) {
        CGRect frame = cell.frame;
        frame.size.width = tableViewWidth;
        cell.frame = frame;
    }
}

- (void)lua_heightForRowCallback:(MLNBlock *)callback
{
     MLNKitLuaAssert(NO, @"Not fount method [AutoFitAdapter heightForCell]!");
}

- (MLNTableViewCell *)tableView:(UITableView *)tableView dequeueCalculCellForIdentifier:(NSString *)identifier
{
    MLNTableViewCell *cell = [self.calculCells objectForKey:identifier];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            [tableView registerClass:[MLNTableViewCell class] forCellReuseIdentifier:identifier];
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        }
        [self.calculCells mln_setObject:cell forKey:identifier];
    }
    return cell;
}

#pragma mark - Getter
- (NSMutableDictionary<NSString *,MLNTableViewCell *> *)calculCells
{
    if (!_calculCells) {
        _calculCells = [NSMutableDictionary dictionary];
    }
    return _calculCells;
}

LUA_EXPORT_BEGIN(MLNTableViewAutoFitAdapter)
LUA_EXPORT_END(MLNTableViewAutoFitAdapter, TableViewAutoFitAdapter, YES, "MLNTableViewAdapter", NULL)

@end
