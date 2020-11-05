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

@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *needUpdateIndexPaths;

@end

@implementation MLNUITableViewAutoFitAdapter

#pragma mark - Private

- (NSMutableArray<NSIndexPath *> *)needUpdateIndexPaths {
    if (!_needUpdateIndexPaths) {
        _needUpdateIndexPaths = [NSMutableArray array];
    }
    return _needUpdateIndexPaths;
}

- (void)reloadCellIfNeeded {
    if (self.needUpdateIndexPaths.count == 0) {
        return;
    }
    [UIView performWithoutAnimation:^{
        [self.targetTableView reloadRowsAtIndexPaths:self.needUpdateIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.needUpdateIndexPaths removeAllObjects];
    }];
}

- (CGSize)cellMaxSize {
    return CGSizeMake(self.targetTableView.frame.size.width, MLNUIUndefined);
}

- (void)prepareToUseCell:(__kindof MLNUITableViewCell *)cell {
    [cell createLuaTableAsCellNameForLuaIfNeed:self.mlnui_luaCore];
    [cell createLayoutNodeIfNeedWithFitSize:self.cellMaxSize /*cell.luaContentView宽度和cell保持一致，高度自适应*/
                                    maxSize:self.cellMaxSize];

}

- (void)markCellNeedReloadWithIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) return;
    if ([self.needUpdateIndexPaths containsObject:indexPath]) {
        return;
    }
    [self.needUpdateIndexPaths addObject:indexPath];
    BOOL isScrolling = [[NSRunLoop currentRunLoop].currentMode isEqualToString:UITrackingRunLoopMode];
    if (isScrolling) {
        return;
    }
    [self reloadCellIfNeeded];
}

#pragma mark - Override

- (Class)tableViewCellClass {
    return [MLNUITableViewAutoHeightCell class];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TICK();
    if ([self.needUpdateIndexPaths containsObject:indexPath]) {
        [self.needUpdateIndexPaths removeObject:indexPath];
    }
    
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
    return tableView.estimatedRowHeight;
}

- (void)luaui_heightForRowCallback:(MLNUIBlock *)callback
{
     MLNUIKitLuaAssert(NO, @"Not fount method [AutoFitAdapter heightForCell]!");
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadCellIfNeeded) object:nil];
    [self performSelector:@selector(reloadCellIfNeeded) withObject:nil afterDelay:0.05];
}

#pragma mark - MLNUITableViewCellDelegate

- (void)mlnuiTableViewCellShouldReload:(MLNUITableViewCell *)cell size:(CGSize)size {
    NSIndexPath *indexPath = [self.targetTableView indexPathForCell:cell];
    if (!indexPath) return;
    NSNumber *cacheHeight = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (cacheHeight && ABS(cacheHeight.floatValue - size.height) < 0.001) {
        return;
    }
    [self.cachesManager updateLayoutInfo:@(size.height) forIndexPath:indexPath];
    [self markCellNeedReloadWithIndexPath:indexPath];
}

#pragma mark - Export

LUAUI_EXPORT_BEGIN(MLNUITableViewAutoFitAdapter)
LUAUI_EXPORT_END(MLNUITableViewAutoFitAdapter, TableViewAutoFitAdapter, YES, "MLNUITableViewAdapter", NULL)

@end
