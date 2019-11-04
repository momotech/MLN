//
//  MMTableViewAdpater.m
//  MLN
//
//  Created by MoMo on 27/02/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "MLNTableViewAdapter.h"
#import "MLNKitHeader.h"
#import "MLNViewExporterMacro.h"
#import "MLNTableView.h"
#import "MLNTableViewCell.h"
#import "MLNBlock.h"
#import "NSDictionary+MLNSafety.h"
#import "MLNTableViewCellSettingProtocol.h"

#define kDefaultPressColor [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]

@interface MLNTableViewAdapter()

@property (nonatomic, strong) MLNBlock *sectionsNumberCallback;
@property (nonatomic, strong) MLNBlock *rowNumbersCallback;
@property (nonatomic, strong) MLNBlock *cellReuseIdCallback;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNBlock *> *selectedRowCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNBlock *> *longPressRowCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNBlock *> *cellWillAppearByReuseIdCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNBlock *> *cellDidDisappearByReuseIdCallbacks;
@property (nonatomic, assign, getter=isShowPressedColor) BOOL showPressedColor;
@property (nonatomic, strong) UIColor *pressedColor;
@end

@implementation MLNTableViewAdapter

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
        _cachesManager = [[MLNAdapterCachesManager alloc] init];
        _pressedColor = kDefaultPressColor;
    }
    return self;
}

- (NSString *)reuseIdAt:(NSIndexPath *)indexPath
{
    if (!self.cellReuseIdCallback) {
        return kMLNTableViewCellReuseID;
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
        MLNKitLuaError(@"The reuse id must be a string and length > 0!");
        return kMLNTableViewCellReuseID;
    }
    // 3. update cache
    [self.cachesManager updateReuseIdentifier:reuseId forIndexPath:indexPath];
    return reuseId;
}

- (MLNBlock *)initedCellCallbackByReuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNBlock *initCellCallback = [self.initedCellCallbacks objectForKey:reuseId];
    if (!initCellCallback) {
        initCellCallback = [self.initedCellCallbacks objectForKey:kMLNTableViewCellReuseID];
    }
    
    return initCellCallback;
}

- (MLNBlock *)fillCellDataCallbackByReuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNBlock *fillCellDataCallback = [self.fillCellDataCallbacks objectForKey:reuseId];
    if (!fillCellDataCallback) {
        fillCellDataCallback = [self.fillCellDataCallbacks objectForKey:kMLNTableViewCellReuseID];
    }
    
    return fillCellDataCallback;
}

- (MLNBlock *)heightForRowCallbackByReuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNBlock *heightForRowCallback = [self.heightForRowCallbacks objectForKey:reuseId];
    if (!heightForRowCallback) {
        heightForRowCallback = [self.heightForRowCallbacks objectForKey:kMLNTableViewCellReuseID];
    }
    
    return heightForRowCallback;
}

- (MLNBlock *)cellWillAppearCallbackByReuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNBlock *cellWillAppearCallback = [self.cellWillAppearByReuseIdCallbacks objectForKey:reuseId];
    if (!cellWillAppearCallback) {
        cellWillAppearCallback = [self.cellWillAppearByReuseIdCallbacks objectForKey:kMLNTableViewCellReuseID];
    }
    
    return cellWillAppearCallback;
}

- (MLNBlock *)cellDidDisappearCallbackByReuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNBlock *cellDidDisappearCallback = [self.cellDidDisappearByReuseIdCallbacks objectForKey:reuseId];
    if (!cellDidDisappearCallback) {
        cellDidDisappearCallback = [self.cellDidDisappearByReuseIdCallbacks objectForKey:kMLNTableViewCellReuseID];
    }
    
    return cellDidDisappearCallback;
}

- (MLNBlock *)selectedRowCallbackByReuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNBlock *selectRowCallback = [self.selectedRowCallbacks objectForKey:reuseId];
    if (!selectRowCallback) {
        selectRowCallback = [self.selectedRowCallbacks objectForKey:kMLNTableViewCellReuseID];
    }
    return selectRowCallback;
}

- (MLNBlock *)longPressRowCallbackByReuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNBlock *longPressRowCallback = [self.longPressRowCallbacks objectForKey:reuseId];
    if (!longPressRowCallback) {
        longPressRowCallback = [self.longPressRowCallbacks objectForKey:kMLNTableViewCellReuseID];
    }
    
    return longPressRowCallback;
}

#pragma mark - UITableViewAdapterDelegate
- (void)setTargetTableView:(UITableView *)targetTableView
{
    _targetTableView = targetTableView;
    [self registerCellClasses];
}

- (void)registerCellClasses
{
    NSDictionary<NSString *, MLNBlock *> *initedCellCallbacks = self.initedCellCallbacks.copy;
    [initedCellCallbacks enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MLNBlock * _Nonnull obj, BOOL * _Nonnull stop) {
        [self.targetTableView registerClass:[MLNTableViewCell class] forCellReuseIdentifier:key];
    }];
    [self.targetTableView registerClass:[MLNTableViewCell class] forCellReuseIdentifier:kMLNTableViewCellReuseID];
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
    MLNKitLuaAssert(numbers && [numbers isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'sectionCount' must be a number!");
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
    MLNKitLuaAssert(itemCountNumber && [itemCountNumber isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'rowCount' must be a number!");
    MLNKitLuaAssert([itemCountNumber integerValue] >= 0, @"The return value of method 'rowCount' must greater or equal than 0!");
    // 3. update cache
    itemCount = [itemCountNumber integerValue];
    [self.cachesManager updateRowCount:itemCount section:section];
    return [itemCountNumber integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdAt:indexPath];
    MLNBlock *initCallback = [self initedCellCallbackByReuseId:reuseId];
    MLNKitLuaAssert(initCallback, @"It must not be nil callback of cell init!");
    if (!initCallback) {
        [self.targetTableView registerClass:[MLNTableViewCell class] forCellReuseIdentifier:reuseId];
    }
    MLNTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    cell.delegate = self;
    [cell pushContentViewWithLuaCore:self.mln_luaCore];
    if (!cell.isInited) {
        [initCallback addLuaTableArgument:[cell getLuaTable]];
        [initCallback callIfCan];
        [cell initCompleted];
    }
    MLNBlock *reuseCallback = [self fillCellDataCallbackByReuseId:reuseId];
    if (reuseCallback) {
        [reuseCallback addLuaTableArgument:[cell getLuaTable]];
        [reuseCallback addIntArgument:(int)indexPath.section+1];
        [reuseCallback addIntArgument:(int)indexPath.row+1];
        [reuseCallback callIfCan];
    }
    [cell requestLayoutIfNeed];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView singleTapSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdAt:indexPath];
    MLNBlock *callback = [self selectedRowCallbackByReuseId:reuseId];
    UITableViewCell<MLNReuseCellProtocol> *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (callback) {
        [callback addLuaTableArgument:[cell getLuaTable]];
        [callback addIntArgument:(int)indexPath.section+1];
        [callback addIntArgument:(int)indexPath.row+1];
        [callback callIfCan];
    }
}

- (void)tableView:(UITableView *)tableView longPressRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = [self reuseIdAt:indexPath];
    MLNBlock *callback = [self longPressRowCallbackByReuseId:reuseId];
    
    UITableViewCell<MLNReuseCellProtocol> *cell = [tableView cellForRowAtIndexPath:indexPath];
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
        return height;
    }
    NSString *reuseId = [self reuseIdAt:indexPath];
    MLNBlock *reuseHeightForRowCallback = [self heightForRowCallbackByReuseId:reuseId];
    MLNKitLuaAssert(reuseHeightForRowCallback, @"The 'heightForCell' callback must not be nil!");
    if (reuseHeightForRowCallback) {
        [reuseHeightForRowCallback addIntArgument:(int)indexPath.section+1];
        [reuseHeightForRowCallback addIntArgument:(int)indexPath.row+1];
        id heightValue = [reuseHeightForRowCallback callIfCan];
        MLNKitLuaAssert(heightValue && [heightValue isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'heightForCell/heightForCellByReuseId' must be a number!");
        height = [heightValue floatValue];
        height = height < 0 ? 0 : height;
        [self.cachesManager updateLayoutInfo:heightValue forIndexPath:indexPath];
        return height;
    }
    return 0.f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell<MLNReuseCellProtocol> *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdAt:indexPath];
    [cell updateLastReueseId:reuseId];
    MLNBlock *cellWillAppearCallback = [self cellWillAppearCallbackByReuseId:reuseId];
    if (cellWillAppearCallback) {
        [cellWillAppearCallback addLuaTableArgument:[cell getLuaTable]];
        [cellWillAppearCallback addIntArgument:(int)indexPath.section+1];
        [cellWillAppearCallback addIntArgument:(int)indexPath.row+1];
        [cellWillAppearCallback callIfCan];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell<MLNReuseCellProtocol> *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *reuseId = [cell lastReueseId];
    if (!(reuseId && reuseId.length > 0)) {
        reuseId = [self reuseIdAt:indexPath];
    }
    MLNBlock *cellDidDisappearCallback = [self cellDidDisappearCallbackByReuseId:reuseId];
    if (cellDidDisappearCallback) {
        [cellDidDisappearCallback addLuaTableArgument:[cell getLuaTable]];
        [cellDidDisappearCallback addIntArgument:(int)indexPath.section+1];
        [cellDidDisappearCallback addIntArgument:(int)indexPath.row+1];
        [cellDidDisappearCallback callIfCan];
    }
}

#pragma mark - MLNTableViewAdapterProtocol
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
- (void)lua_selectedRow:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.targetTableView registerClass:[MLNTableViewCell class] forCellReuseIdentifier:reuseId];
        [self.selectedRowCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_selectedRowCallback:(MLNBlock *)callback
{
    [self lua_selectedRow:kMLNTableViewCellReuseID callback:callback];
}

- (void)lua_longPressRow:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.targetTableView registerClass:[MLNTableViewCell class] forCellReuseIdentifier:reuseId];
        [self.longPressRowCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_longPressRowCallback:(MLNBlock *)callback
{
    [self lua_longPressRow:kMLNTableViewCellReuseID callback:callback];
}

- (void)lua_cellWillAppearCallback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    [self.cellWillAppearByReuseIdCallbacks setObject:callback forKey:kMLNTableViewCellReuseID];
}

- (void)lua_cellDidDisappearCallback:(MLNBlock *)callback
{
    [self.cellDidDisappearByReuseIdCallbacks setObject:callback forKey:kMLNTableViewCellReuseID];
}

- (void)lua_cellWillAppear:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    [self.cellWillAppearByReuseIdCallbacks setObject:callback forKey:reuseId];
}

- (void)lua_cellDidDisappear:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    [self.cellDidDisappearByReuseIdCallbacks setObject:callback forKey:reuseId];
}

#pragma mark - Save data Callback
- (void)lua_numbersOfSections:(MLNBlock *)callback
{
    self.sectionsNumberCallback = callback;
}

- (void)lua_numberOfRowsInSection:(MLNBlock *)callback
{
    self.rowNumbersCallback = callback;
}

- (void)lua_reuseIdWithCallback:(MLNBlock *)callback
{
    self.cellReuseIdCallback = callback;
}

- (void)lua_initCellBy:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.targetTableView registerClass:[MLNTableViewCell class] forCellReuseIdentifier:reuseId];
        [self.initedCellCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_reuseCellBy:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.targetTableView registerClass:[MLNTableViewCell class] forCellReuseIdentifier:reuseId];
        [self.fillCellDataCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_heightForRowBy:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.heightForRowCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_initCellCallback:(MLNBlock *)callback
{
    [self lua_initCellBy:kMLNTableViewCellReuseID callback:callback];
}

- (void)lua_reuseCellCallback:(MLNBlock *)callback
{
    [self lua_reuseCellBy:kMLNTableViewCellReuseID callback:callback];
}

- (void)lua_heightForRowCallback:(MLNBlock *)callback
{
    [self lua_heightForRowBy:kMLNTableViewCellReuseID callback:callback];
}


#pragma mark - Setup For Lua
LUA_EXPORT_BEGIN(MLNTableViewAdapter)
LUA_EXPORT_METHOD(sectionCount, "lua_numbersOfSections:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(rowCount, "lua_numberOfRowsInSection:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(reuseId, "lua_reuseIdWithCallback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(initCellByReuseId, "lua_initCellBy:callback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(fillCellDataByReuseId, "lua_reuseCellBy:callback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(initCell, "lua_initCellCallback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(fillCellData, "lua_reuseCellCallback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(selectedRowByReuseId, "lua_selectedRow:callback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(selectedRow, "lua_selectedRowCallback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(longPressRowByReuseId, "lua_longPressRow:callback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(longPressRow, "lua_longPressRowCallback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(heightForCell, "lua_heightForRowCallback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(heightForCellByReuseId, "lua_heightForRowBy:callback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(cellWillAppear, "lua_cellWillAppearCallback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(cellDidDisappear, "lua_cellDidDisappearCallback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(cellWillAppearByReuseId, "lua_cellWillAppear:callback:", MLNTableViewAdapter)
LUA_EXPORT_METHOD(cellDidDisappearByReuseId, "lua_cellDidDisappear:callback:", MLNTableViewAdapter)
LUA_EXPORT_PROPERTY(showPressed, "setShowPressedColor:", "showPressedColor",MLNTableViewAdapter)
LUA_EXPORT_PROPERTY(pressedColor, "setPressedColor:","pressedColor", MLNTableViewAdapter)
LUA_EXPORT_END(MLNTableViewAdapter, TableViewAdapter, NO, NULL, NULL)

@end
