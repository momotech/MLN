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
        [self.targetTableView registerClass:[MLNUITableViewCell class] forCellReuseIdentifier:key];
    }];
    [self.targetTableView registerClass:[MLNUITableViewCell class] forCellReuseIdentifier:kMLNUITableViewCellReuseID];
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
        [self.targetTableView registerClass:[MLNUITableViewCell class] forCellReuseIdentifier:reuseId];
    }
    MLNUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    cell.delegate = self;
    [cell pushContentViewWithLuaCore:self.mln_luaCore];
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
    [cell requestLayoutIfNeed];
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
        return height;
    }
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
- (void)lua_selectedRow:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.targetTableView registerClass:[MLNUITableViewCell class] forCellReuseIdentifier:reuseId];
        [self.selectedRowCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_selectedRowCallback:(MLNUIBlock *)callback
{
    [self lua_selectedRow:kMLNUITableViewCellReuseID callback:callback];
}

- (void)lua_longPressRow:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.targetTableView registerClass:[MLNUITableViewCell class] forCellReuseIdentifier:reuseId];
        [self.longPressRowCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_longPressRowCallback:(MLNUIBlock *)callback
{
    [self lua_longPressRow:kMLNUITableViewCellReuseID callback:callback];
}

- (void)lua_cellWillAppearCallback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    [self.cellWillAppearByReuseIdCallbacks setObject:callback forKey:kMLNUITableViewCellReuseID];
}

- (void)lua_cellDidDisappearCallback:(MLNUIBlock *)callback
{
    [self.cellDidDisappearByReuseIdCallbacks setObject:callback forKey:kMLNUITableViewCellReuseID];
}

- (void)lua_cellWillAppear:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    [self.cellWillAppearByReuseIdCallbacks setObject:callback forKey:reuseId];
}

- (void)lua_cellDidDisappear:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    [self.cellDidDisappearByReuseIdCallbacks setObject:callback forKey:reuseId];
}

#pragma mark - Save data Callback
- (void)lua_numbersOfSections:(MLNUIBlock *)callback
{
    self.sectionsNumberCallback = callback;
}

- (void)lua_numberOfRowsInSection:(MLNUIBlock *)callback
{
    self.rowNumbersCallback = callback;
}

- (void)lua_reuseIdWithCallback:(MLNUIBlock *)callback
{
    self.cellReuseIdCallback = callback;
}

- (void)lua_initCellBy:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.targetTableView registerClass:[MLNUITableViewCell class] forCellReuseIdentifier:reuseId];
        [self.initedCellCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_reuseCellBy:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.targetTableView registerClass:[MLNUITableViewCell class] forCellReuseIdentifier:reuseId];
        [self.fillCellDataCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_heightForRowBy:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.heightForRowCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_initCellCallback:(MLNUIBlock *)callback
{
    [self lua_initCellBy:kMLNUITableViewCellReuseID callback:callback];
}

- (void)lua_reuseCellCallback:(MLNUIBlock *)callback
{
    [self lua_reuseCellBy:kMLNUITableViewCellReuseID callback:callback];
}

- (void)lua_heightForRowCallback:(MLNUIBlock *)callback
{
    [self lua_heightForRowBy:kMLNUITableViewCellReuseID callback:callback];
}


#pragma mark - Setup For Lua
LUA_EXPORT_BEGIN(MLNUITableViewAdapter)
LUA_EXPORT_METHOD(sectionCount, "lua_numbersOfSections:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(rowCount, "lua_numberOfRowsInSection:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(reuseId, "lua_reuseIdWithCallback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(initCellByReuseId, "lua_initCellBy:callback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(fillCellDataByReuseId, "lua_reuseCellBy:callback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(initCell, "lua_initCellCallback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(fillCellData, "lua_reuseCellCallback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(selectedRowByReuseId, "lua_selectedRow:callback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(selectedRow, "lua_selectedRowCallback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(longPressRowByReuseId, "lua_longPressRow:callback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(longPressRow, "lua_longPressRowCallback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(heightForCell, "lua_heightForRowCallback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(heightForCellByReuseId, "lua_heightForRowBy:callback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(cellWillAppear, "lua_cellWillAppearCallback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(cellDidDisappear, "lua_cellDidDisappearCallback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(cellWillAppearByReuseId, "lua_cellWillAppear:callback:", MLNUITableViewAdapter)
LUA_EXPORT_METHOD(cellDidDisappearByReuseId, "lua_cellDidDisappear:callback:", MLNUITableViewAdapter)
LUA_EXPORT_PROPERTY(showPressed, "setShowPressedColor:", "showPressedColor",MLNUITableViewAdapter)
LUA_EXPORT_PROPERTY(pressedColor, "setPressedColor:","pressedColor", MLNUITableViewAdapter)
LUA_EXPORT_END(MLNUITableViewAdapter, TableViewAdapter, NO, NULL, NULL)

@end
