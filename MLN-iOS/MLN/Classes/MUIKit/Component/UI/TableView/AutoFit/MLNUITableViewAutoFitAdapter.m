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
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@end

@implementation MLNUITableViewAutoFitAdapter

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.currentIndexPath = indexPath;
//    MLNUITableViewCell *cell = (MLNUITableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
//    self.currentIndexPath = nil;
//
//    if (![self.cachesManager layoutInfoWithIndexPath:indexPath]) {
////        CGFloat tableViewWidth = tableView.frame.size.width;
////        [self updateCellWidthIfNeed:cell tableViewWidth:tableViewWidth];
//////        [cell pushContentViewWithLuaCore:self.mlnui_luaCore];
////        CGFloat height = [cell calculHeightWithWidth:tableViewWidth maxHeight:MLNUIUndefined];
//        CGFloat height = cell.luaContentView.mlnui_layoutNode.layoutHeight;
//        [self.cachesManager updateLayoutInfo:@(height) forIndexPath:indexPath];
//    }
    TICK();
    self.currentIndexPath = indexPath;
    NSString *reuseId = [self reuseIdAt:indexPath];
    MLNUIBlock *initCallback = [self initedCellCallbackByReuseId:reuseId];
    MLNUIKitLuaAssert(initCallback, @"It must not be nil callback of cell init!");
    if (!initCallback) {
        [self.targetTableView registerClass:[MLNUITableViewCell class] forCellReuseIdentifier:reuseId];
    }
    MLNUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    cell.delegate = self;
    TOCK("befor init %zd",indexPath.row);
    [cell pushContentViewWithLuaCore:self.mlnui_luaCore];
    if (!cell.isInited) {
        [initCallback addLuaTableArgument:[cell getLuaTable]];
        [initCallback callIfCan];
        [cell initCompleted];
        TOCK("init ");
    }
    //TODO: 如果高度有缓存，则不需要调用fillCellData？
    MLNUIBlock *reuseCallback = [self fillCellDataCallbackByReuseId:reuseId];
    if (reuseCallback) {
        [reuseCallback addLuaTableArgument:[cell getLuaTable]];
        [reuseCallback addIntArgument:(int)indexPath.section+1];
        [reuseCallback addIntArgument:(int)indexPath.row+1];
        [reuseCallback callIfCan];
        TOCK("fill cell data");
    }
//    [cell mlnui_requestLayoutIfNeed];
    __block CGFloat height = CGFloatValueFromNumber([self.cachesManager layoutInfoWithIndexPath:indexPath]);
    if (height <= 0) {
//        NSLog(@">>>>>> cell %p row %zd calculate height",cell,indexPath.row);
        CGFloat tableViewWidth = tableView.frame.size.width;
        height = [cell calculHeightWithWidth:tableViewWidth maxHeight:MLNUIUndefined applySize:YES];
        if (![self.cachesManager layoutInfoWithIndexPath:indexPath]) {
    //        [self updateCellWidthIfNeed:cell tableViewWidth:tableViewWidth];
            [self.cachesManager updateLayoutInfo:@(height) forIndexPath:indexPath];
        }
        TOCK("caculate height");
    }
    self.currentIndexPath = nil;
    TOCKALL("cell for row %zd",indexPath.row);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = CGFloatValueFromNumber([self.cachesManager layoutInfoWithIndexPath:indexPath]);
    if (height > 0) {
//        NSLog(@">>>>>> height from cache, row %zd %.2f ",indexPath.row, height);
        return height;
    }
    
    if (self.currentIndexPath && self.currentIndexPath.section == indexPath.section && self.currentIndexPath.row == indexPath.row) {
//        NSLog(@">>>>>> height estimatedRowHeight, row %zd %.2f ",indexPath.row, tableView.estimatedRowHeight);
        return tableView.estimatedRowHeight;
    }
    
//    NSLog(@">>>>>> height, row %zd",indexPath.row);
//    NSAssert(NO, @"should not reach here");
    
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
