//
//  MMTableViewAdpater.m
//  MLNUI
//
//  Created by MoMo on 27/02/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "MLNUITableViewAdapter.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUITableView.h"
#import "MLNUITableViewCell.h"
#import "MLNUIBlock.h"
#import "NSDictionary+MLNUISafety.h"
#import "MLNUITableViewCellSettingProtocol.h"

#define kMUIDefaultPressColor [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]

@interface MLNUITableViewAdapter()<MLNUITableViewCellSettingProtocol>

@property (nonatomic, strong) MLNUIBlock *sectionsNumberCallback;
@property (nonatomic, strong) MLNUIBlock *rowNumbersCallback;
@property (nonatomic, strong) MLNUIBlock *cellReuseIdCallback;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUIBlock *> *selectedRowCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUIBlock *> *longPressRowCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUIBlock *> *cellWillAppearByReuseIdCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUIBlock *> *cellDidDisappearByReuseIdCallbacks;
@property (nonatomic, assign, getter=isShowPressedColor) BOOL showPressedColor;
@property (nonatomic, strong) UIColor *pressedColor;
@end

@implementation MLNUITableViewAdapter

- (instancetype)init
{
    if (self = [super init]) {
        _initedCellCallbacks = [NSMutableDictionary dictionary];
        _fillCellDataCallbacks = [NSMutableDictionary dictionary];
        _heightForRowCallbacks = [NSMutableDictionary dictionary];
        _selectedRowCallbacks = [NSMutableDictionary dictionary];
        _longPressRowCallbacks = [NSMutableDictionary dictionary];
        _cellWillAppearByReuseIdCallbacks = [NSMutableDictionary dictionary];
        _cellDidDisappearByReuseIdCallbacks = [NSMutableDictionary dictionary];
        _cachesManager = [[MLNUIAdapterCachesManager alloc] init];
        _pressedColor = kMUIDefaultPressColor;
    }
    return self;
}

- (NSString *)reuseIdAt:(NSIndexPath *)indexPath
{
    if (!self.cellReuseIdCallback) {
        return kMLNUITableViewCellReuseID;
    }
    NSString *reuseId = [self.cachesManager reuseIdentifierWithIndexPath:indexPath];
    if (reuseId) {
        return reuseId;
    }
    // 2. call lua
    [self.cellReuseIdCallback addIntArgument:(int)indexPath.section+1];
    [self.cellReuseIdCallback addIntArgument:(int)indexPath.item+1];
    reuseId = [self.cellReuseIdCallback callIfCan];
    if (!(reuseId && [reuseId isKindOfClass:[NSString class]] && reuseId.length > 0)) {
        MLNUIKitLuaError(@"The reuse id must be a string and length > 0!");
        return kMLNUITableViewCellReuseID;
    }
    // 3. update cache
    [self.cachesManager updateReuseIdentifier:reuseId forIndexPath:indexPath];
    return reuseId;
}

- (MLNUIBlock *)initedCellCallbackByReuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIBlock *initCellCallback = [self.initedCellCallbacks objectForKey:reuseId];
    if (!initCellCallback) {
        initCellCallback = [self.initedCellCallbacks objectForKey:kMLNUITableViewCellReuseID];
    }
    
    return initCellCallback;
}

- (MLNUIBlock *)fillCellDataCallbackByReuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIBlock *fillCellDataCallback = [self.fillCellDataCallbacks objectForKey:reuseId];
    if (!fillCellDataCallback) {
        fillCellDataCallback = [self.fillCellDataCallbacks objectForKey:kMLNUITableViewCellReuseID];
    }
    
    return fillCellDataCallback;
}

- (MLNUIBlock *)heightForRowCallbackByReuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIBlock *heightForRowCallback = [self.heightForRowCallbacks objectForKey:reuseId];
    if (!heightForRowCallback) {
        heightForRowCallback = [self.heightForRowCallbacks objectForKey:kMLNUITableViewCellReuseID];
    }
    
    return heightForRowCallback;
}

- (MLNUIBlock *)cellWillAppearCallbackByReuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIBlock *cellWillAppearCallback = [self.cellWillAppearByReuseIdCallbacks objectForKey:reuseId];
    if (!cellWillAppearCallback) {
        cellWillAppearCallback = [self.cellWillAppearByReuseIdCallbacks objectForKey:kMLNUITableViewCellReuseID];
    }
    
    return cellWillAppearCallback;
}

- (MLNUIBlock *)cellDidDisappearCallbackByReuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIBlock *cellDidDisappearCallback = [self.cellDidDisappearByReuseIdCallbacks objectForKey:reuseId];
    if (!cellDidDisappearCallback) {
        cellDidDisappearCallback = [self.cellDidDisappearByReuseIdCallbacks objectForKey:kMLNUITableViewCellReuseID];
    }
    
    return cellDidDisappearCallback;
}

- (MLNUIBlock *)selectedRowCallbackByReuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIBlock *selectRowCallback = [self.selectedRowCallbacks objectForKey:reuseId];
    if (!selectRowCallback) {
        selectRowCallback = [self.selectedRowCallbacks objectForKey:kMLNUITableViewCellReuseID];
    }
    return selectRowCallback;
}

- (MLNUIBlock *)longPressRowCallbackByReuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIBlock *longPressRowCallback = [self.longPressRowCallbacks objectForKey:reuseId];
    if (!longPressRowCallback) {
        longPressRowCallback = [self.longPressRowCallbacks objectForKey:kMLNUITableViewCellReuseID];
    }
    
    return longPressRowCallback;
}

- (Class)tableViewCellClass {
    return [MLNUITableViewCell class];
}

#pragma mark - Private

- (void)prepareToUseCell:(MLNUITableViewCell *)cell {
    [cell createLuaTableAsCellNameForLuaIfNeed:self.mlnui_luaCore];
    [cell createLayoutNodeIfNeedWithFitSize:cell.frame.size /*cell.luaContentView大小要和cell保持一致*/
                                    maxSize:cell.frame.size];
}

#pragma mark - UITableViewAdapterDelegate
- (void)setTargetTableView:(UITableView *)targetTableView
{
    _targetTableView = targetTableView;
    [self registerCellClasses];
}

- (void)registerCellClasses
{
    NSDictionary<NSString *, MLNUIBlock *> *initedCellCallbacks = self.initedCellCallbacks.copy;
    [initedCellCallbacks enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MLNUIBlock * _Nonnull obj, BOOL * _Nonnull stop) {
        [self.targetTableView registerClass:self.tableViewCellClass forCellReuseIdentifier:key];
    }];
    [self.targetTableView registerClass:self.tableViewCellClass forCellReuseIdentifier:kMLNUITableViewCellReuseID];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // 1. cache
    NSInteger sectionCount = [self.cachesManager sectionCount];
    if (sectionCount > 0) {
        return sectionCount;
    }
    // 2. call lua
    if (!self.sectionsNumberCallback) {
        [self.cachesManager updateSectionCount:1];
        return 1;
    }
    id numbers = [self.sectionsNumberCallback callIfCan];
    MLNUIKitLuaAssert(numbers && [numbers isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'sectionCount' must be a number!");
    // 3. update cache
    sectionCount = [numbers integerValue];
    [self.cachesManager updateSectionCount:sectionCount];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.rowNumbersCallback) {
        return 0;
    }
    // 1. cache
    NSInteger itemCount = [self.cachesManager rowCountInSection:section];
    if (itemCount > 0) {
        return itemCount;
    }
    // 2. call lua
    [self.rowNumbersCallback addIntArgument:(int)section+1];
    id itemCountNumber = [self.rowNumbersCallback callIfCan];
    MLNUIKitLuaAssert(itemCountNumber && [itemCountNumber isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'rowCount' must be a number!");
    MLNUIKitLuaAssert([itemCountNumber integerValue] >= 0, @"The return value of method 'rowCount' must greater or equal than 0!");
    // 3. update cache
    itemCount = [itemCountNumber integerValue];
    [self.cachesManager updateRowCount:itemCount section:section];
    return [itemCountNumber integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdAt:indexPath];
    MLNUIBlock *initCallback = [self initedCellCallbackByReuseId:reuseId];
    MLNUIKitLuaAssert(initCallback, @"It must not be nil callback of cell init!");
    if (!initCallback) {
        [self.targetTableView registerClass:self.tableViewCellClass forCellReuseIdentifier:reuseId];
    }
    MLNUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    cell.delegate = self;
    [self prepareToUseCell:cell];
    
    if (!cell.isInited) {
        [initCallback addLuaTableArgument:[cell getLuaTable]];
        [initCallback callIfCan];
        [cell initCompleted];
    }
    MLNUIBlock *reuseCallback = [self fillCellDataCallbackByReuseId:reuseId];
    if (reuseCallback) {
        [reuseCallback addLuaTableArgument:[cell getLuaTable]];
        [reuseCallback addIntArgument:(int)indexPath.section+1];
        [reuseCallback addIntArgument:(int)indexPath.row+1];
        [reuseCallback callIfCan];
    }
//    [cell mlnui_requestLayoutIfNeed];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView singleTapSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdAt:indexPath];
    MLNUIBlock *callback = [self selectedRowCallbackByReuseId:reuseId];
    UITableViewCell<MLNUIReuseCellProtocol> *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (callback) {
        [callback addLuaTableArgument:[cell getLuaTable]];
        [callback addIntArgument:(int)indexPath.section+1];
        [callback addIntArgument:(int)indexPath.row+1];
        [callback callIfCan];
    }
}

- (void)tableView:(UITableView *)tableView longPressRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = [self reuseIdAt:indexPath];
    MLNUIBlock *callback = [self longPressRowCallbackByReuseId:reuseId];
    
    UITableViewCell<MLNUIReuseCellProtocol> *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (callback) {
        [callback addLuaTableArgument:[cell getLuaTable]];
        [callback addIntArgument:(int)indexPath.section+1];
        [callback addIntArgument:(int)indexPath.row+1];
        [callback callIfCan];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = CGFloatValueFromNumber([self.cachesManager layoutInfoWithIndexPath:indexPath]);
    if (height > 0) {
//        NSLog(@">>>>>> height form cache, row %zd",indexPath.row);
        return height;
    }
//    NSLog(@">>>>>> height, row %zd",indexPath.row);

    NSString *reuseId = [self reuseIdAt:indexPath];
    MLNUIBlock *reuseHeightForRowCallback = [self heightForRowCallbackByReuseId:reuseId];
    MLNUIKitLuaAssert(reuseHeightForRowCallback, @"The 'heightForCell' callback must not be nil!");
    if (reuseHeightForRowCallback) {
        [reuseHeightForRowCallback addIntArgument:(int)indexPath.section+1];
        [reuseHeightForRowCallback addIntArgument:(int)indexPath.row+1];
        id heightValue = [reuseHeightForRowCallback callIfCan];
        MLNUIKitLuaAssert(heightValue && [heightValue isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'heightForCell/heightForCellByReuseId' must be a number!");
        height = [heightValue floatValue];
        height = height < 0 ? 0 : height;
        [self.cachesManager updateLayoutInfo:heightValue forIndexPath:indexPath];
        return height;
    }
    return 0.f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell<MLNUIReuseCellProtocol> *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdAt:indexPath];
    [cell updateLastReueseId:reuseId];
    MLNUIBlock *cellWillAppearCallback = [self cellWillAppearCallbackByReuseId:reuseId];
    if (cellWillAppearCallback) {
        [cellWillAppearCallback addLuaTableArgument:[cell getLuaTable]];
        [cellWillAppearCallback addIntArgument:(int)indexPath.section+1];
        [cellWillAppearCallback addIntArgument:(int)indexPath.row+1];
        [cellWillAppearCallback callIfCan];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell<MLNUIReuseCellProtocol> *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *reuseId = [cell lastReueseId];
    if (!(reuseId && reuseId.length > 0)) {
        reuseId = [self reuseIdAt:indexPath];
    }
    MLNUIBlock *cellDidDisappearCallback = [self cellDidDisappearCallbackByReuseId:reuseId];
    if (cellDidDisappearCallback) {
        [cellDidDisappearCallback addLuaTableArgument:[cell getLuaTable]];
        [cellDidDisappearCallback addIntArgument:(int)indexPath.section+1];
        [cellDidDisappearCallback addIntArgument:(int)indexPath.row+1];
        [cellDidDisappearCallback callIfCan];
    }
}

#pragma mark - MLNUITableViewAdapterProtocol
- (void)tableView:(UITableView *)tableView deleteRowsAtSection:(NSInteger)section startItem:(NSInteger)startItem endItem:(NSInteger)endItem indexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.cachesManager deleteAtSection:section start:startItem end:endItem indexPaths:indexPaths];
}

- (void)tableView:(UITableView *)tableView insertRowsAtSection:(NSInteger)section startItem:(NSInteger)startItem endItem:(NSInteger)endItem
{
    [self.cachesManager insertAtSection:section start:startItem end:endItem];
}

- (void)tableViewReloadData:(UITableView *)tableView
{
    [self.cachesManager invalidateAllCaches];
}

- (void)tableView:(UITableView *)tableView reloadSections:(NSIndexSet *)sections
{
    [self.cachesManager invalidateWithSections:sections];
}

- (void)tableView:(UITableView *)tableView reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.cachesManager invalidateWithIndexPaths:indexPaths];
}

#pragma mark - Extension Functions For Lua
- (void)luaui_selectedRow:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.targetTableView registerClass:self.tableViewCellClass forCellReuseIdentifier:reuseId];
        [self.selectedRowCallbacks mlnui_setObject:callback forKey:reuseId];
    }
}

- (void)luaui_selectedRowCallback:(MLNUIBlock *)callback
{
    [self luaui_selectedRow:kMLNUITableViewCellReuseID callback:callback];
}

- (void)luaui_longPressRow:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.targetTableView registerClass:self.tableViewCellClass forCellReuseIdentifier:reuseId];
        [self.longPressRowCallbacks mlnui_setObject:callback forKey:reuseId];
    }
}

- (void)luaui_longPressRowCallback:(MLNUIBlock *)callback
{
    [self luaui_longPressRow:kMLNUITableViewCellReuseID callback:callback];
}

- (void)luaui_cellWillAppearCallback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    [self.cellWillAppearByReuseIdCallbacks setObject:callback forKey:kMLNUITableViewCellReuseID];
}

- (void)luaui_cellDidDisappearCallback:(MLNUIBlock *)callback
{
    [self.cellDidDisappearByReuseIdCallbacks setObject:callback forKey:kMLNUITableViewCellReuseID];
}

- (void)luaui_cellWillAppear:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    [self.cellWillAppearByReuseIdCallbacks setObject:callback forKey:reuseId];
}

- (void)luaui_cellDidDisappear:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    [self.cellDidDisappearByReuseIdCallbacks setObject:callback forKey:reuseId];
}

#pragma mark - Save data Callback
- (void)luaui_numbersOfSections:(MLNUIBlock *)callback
{
    self.sectionsNumberCallback = callback;
}

- (void)luaui_numberOfRowsInSection:(MLNUIBlock *)callback
{
    self.rowNumbersCallback = callback;
}

- (void)luaui_reuseIdWithCallback:(MLNUIBlock *)callback
{
    self.cellReuseIdCallback = callback;
}

- (void)luaui_initCellBy:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.targetTableView registerClass:self.tableViewCellClass forCellReuseIdentifier:reuseId];
        [self.initedCellCallbacks mlnui_setObject:callback forKey:reuseId];
    }
}

- (void)luaui_reuseCellBy:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.targetTableView registerClass:self.tableViewCellClass forCellReuseIdentifier:reuseId];
        [self.fillCellDataCallbacks mlnui_setObject:callback forKey:reuseId];
    }
}

- (void)luaui_heightForRowBy:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.heightForRowCallbacks mlnui_setObject:callback forKey:reuseId];
    }
}

- (void)luaui_initCellCallback:(MLNUIBlock *)callback
{
    [self luaui_initCellBy:kMLNUITableViewCellReuseID callback:callback];
}

- (void)luaui_reuseCellCallback:(MLNUIBlock *)callback
{
    [self luaui_reuseCellBy:kMLNUITableViewCellReuseID callback:callback];
}

- (void)luaui_heightForRowCallback:(MLNUIBlock *)callback
{
    [self luaui_heightForRowBy:kMLNUITableViewCellReuseID callback:callback];
}


#pragma mark - Setup For Lua
LUAUI_EXPORT_BEGIN(MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(sectionCount, "luaui_numbersOfSections:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(rowCount, "luaui_numberOfRowsInSection:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(reuseId, "luaui_reuseIdWithCallback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(initCellByReuseId, "luaui_initCellBy:callback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(fillCellDataByReuseId, "luaui_reuseCellBy:callback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(initCell, "luaui_initCellCallback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(fillCellData, "luaui_reuseCellCallback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(selectedRowByReuseId, "luaui_selectedRow:callback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(selectedRow, "luaui_selectedRowCallback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(longPressRowByReuseId, "luaui_longPressRow:callback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(longPressRow, "luaui_longPressRowCallback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(heightForCell, "luaui_heightForRowCallback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(heightForCellByReuseId, "luaui_heightForRowBy:callback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(cellWillAppear, "luaui_cellWillAppearCallback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(cellDidDisappear, "luaui_cellDidDisappearCallback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(cellWillAppearByReuseId, "luaui_cellWillAppear:callback:", MLNUITableViewAdapter)
LUAUI_EXPORT_METHOD(cellDidDisappearByReuseId, "luaui_cellDidDisappear:callback:", MLNUITableViewAdapter)
LUAUI_EXPORT_PROPERTY(showPressed, "setShowPressedColor:", "showPressedColor",MLNUITableViewAdapter)
LUAUI_EXPORT_PROPERTY(pressedColor, "setPressedColor:","pressedColor", MLNUITableViewAdapter)
LUAUI_EXPORT_END(MLNUITableViewAdapter, TableViewAdapter, NO, NULL, NULL)

@end
