//
//  MLNUICollectionViewAdapter.m
//
//
//  Created by MoMo on 2018/7/9.
//

#import "MLNUICollectionViewAdapter.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUICollectionViewCell.h"
#import "MLNUIBlock.h"
#import "NSDictionary+MLNUISafety.h"


#define kReuseIndentifierPlaceholder @"kReuseIndentifierPlaceholder"

@interface MLNUICollectionViewAdapter()

@property (nonatomic, strong) MLNUIBlock *sectionCountCallback;
@property (nonatomic, strong) MLNUIBlock *itemCountCallback;
@property (nonatomic, strong) MLNUIBlock *cellReuseIdCallback;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUIBlock *> *selectedRowCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUIBlock *> *longPressRowCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUIBlock *> *sizeForCellCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUIBlock *> *cellWillAppearCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUIBlock *> *cellDidDisappearCallbacks;


@end

@implementation MLNUICollectionViewAdapter

static NSNumber *kNumberZero = nil;
static NSValue *kSizeValueZero = nil;
- (instancetype)init
{
    if (self = [super init]) {
        // callbacks
        _initedCellCallbacks = [NSMutableDictionary dictionary];
        _reuseCellCallbacks = [NSMutableDictionary dictionary];
        _sizeForCellCallbacks = [NSMutableDictionary dictionary];
        _selectedRowCallbacks = [NSMutableDictionary dictionary];
        _longPressRowCallbacks = [NSMutableDictionary dictionary];
        _cellWillAppearCallbacks = [NSMutableDictionary dictionary];
        _cellDidDisappearCallbacks = [NSMutableDictionary dictionary];
        
        // caches
        _cachesManager = [[MLNUIAdapterCachesManager alloc] init];
    }
    return self;
}

- (void)registerCellClassIfNeed:(UICollectionView *)collectionView  reuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(collectionView, @"collectionView view must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length > 0 , @"The reuse id must not be nil!");
    
    NSMutableDictionary* classDict = [self collectionViewRegisterCellClassDict:collectionView];
    if (reuseId && reuseId.length > 0 && ![classDict valueForKey:reuseId]) {
        [collectionView registerClass:[MLNUICollectionViewCell class] forCellWithReuseIdentifier:reuseId];
        //[self.cellReuseIds addObject:reuseId];
    }
}

- (NSMutableDictionary *)collectionViewRegisterCellClassDict:(UICollectionView*)collectionView {
    return [collectionView valueForKey:@"_cellClassDict"];
}

#pragma mark - MLNUICollectionViewAdapterProtocol
@synthesize collectionView;
- (NSString *)reuseIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.cellReuseIdCallback) {
        return kMLNUICollectionViewCellReuseID;
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
        return kMLNUICollectionViewCellReuseID;
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
        initCellCallback = [self.initedCellCallbacks objectForKey:kMLNUICollectionViewCellReuseID];
    }
    
    return initCellCallback;
}

- (MLNUIBlock *)fillCellDataCallbackByReuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIBlock *fillCellDataCallback = [self.reuseCellCallbacks objectForKey:reuseId];
    if (!fillCellDataCallback) {
        fillCellDataCallback = [self.reuseCellCallbacks objectForKey:kMLNUICollectionViewCellReuseID];
    }
    
    return fillCellDataCallback;
}

- (MLNUIBlock *)sizeForCellCallbackByReuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIBlock *sizeForCellCallback = [self.sizeForCellCallbacks objectForKey:reuseId];
    if (!sizeForCellCallback) {
        sizeForCellCallback = [self.sizeForCellCallbacks objectForKey:kMLNUICollectionViewCellReuseID];
    }
    
    return sizeForCellCallback;
}

- (MLNUIBlock *)cellWillAppearCallbackByReuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIBlock *cellWillAppearCallback = [self.cellWillAppearCallbacks objectForKey:reuseId];
    if (!cellWillAppearCallback) {
        cellWillAppearCallback = [self.cellWillAppearCallbacks objectForKey:kMLNUICollectionViewCellReuseID];
    }
    
    return cellWillAppearCallback;
}

- (MLNUIBlock *)cellDidDisappearCallbackByReuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIBlock *cellDidDisappearCallback = [self.cellDidDisappearCallbacks objectForKey:reuseId];
    if (!cellDidDisappearCallback) {
        cellDidDisappearCallback = [self.cellDidDisappearCallbacks objectForKey:kMLNUICollectionViewCellReuseID];
    }
    return cellDidDisappearCallback;
}

- (MLNUIBlock *)selectedRowCallbackByReuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIBlock *selectRowCallback = [self.selectedRowCallbacks objectForKey:reuseId];
    if (!selectRowCallback) {
        selectRowCallback = [self.selectedRowCallbacks objectForKey:kMLNUICollectionViewCellReuseID];
    }
    return selectRowCallback;
}

- (MLNUIBlock *)longPressRowCallbackByReuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUIBlock *longPressRowCallback = [self.longPressRowCallbacks objectForKey:reuseId];
    if (!longPressRowCallback) {
        longPressRowCallback = [self.longPressRowCallbacks objectForKey:kMLNUICollectionViewCellReuseID];
    }
    return longPressRowCallback;
}

- (void)collectionViewReloadData:(UICollectionView *)collectionView
{
    [self.cachesManager invalidateAllCaches];
}

- (void)collectionView:(UICollectionView *)collectionView reloadSections:(NSIndexSet *)sections
{
    [self.cachesManager invalidateWithSections:sections];
}

- (void)collectionView:(UICollectionView *)collectionView reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.cachesManager invalidateWithIndexPaths:indexPaths];
}

- (void)collectionView:(UICollectionView *)collectionView insertItemsAtSection:(NSInteger)section startItem:(NSInteger)startItem endItem:(NSInteger)endItem
{
    [self.cachesManager insertAtSection:section start:startItem end:endItem];
}

- (void)collectionView:(UICollectionView *)collectionView deleteItemsAtSection:(NSInteger)section startItem:(NSInteger)startItem endItem:(NSInteger)endItem indexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.cachesManager deleteAtSection:section start:startItem end:endItem indexPaths:indexPaths];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // 1. cache
    NSInteger sectionCount = [self.cachesManager sectionCount];
    if (sectionCount > 0) {
        return sectionCount;
    }
    // 2. call lua
    if (!self.sectionCountCallback) {
        [self.cachesManager updateSectionCount:1];
        return 1;
    }
    id numbers = [self.sectionCountCallback callIfCan];
    MLNUIKitLuaAssert(numbers && [numbers isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'sectionCount' must be a number!");
    MLNUIKitLuaAssert([numbers integerValue] > 0, @"The return value of method 'sectionCount' must greater than 0!");
    // 3. update cache
    sectionCount = [numbers integerValue];
    [self.cachesManager updateSectionCount:sectionCount];
    return sectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!self.itemCountCallback) {
        return 0;
    }
    // 1. cache
    NSInteger itemCount = [self.cachesManager rowCountInSection:section];
    if (itemCount > 0) {
        return itemCount;
    }
    // 2. call lua
    [self.itemCountCallback addIntArgument:(int)section+1];
    id itemCountNumber = [self.itemCountCallback callIfCan];
    MLNUIKitLuaAssert(itemCountNumber && [itemCountNumber isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'rowCount' must be a number!");
    // 3. update cache
    itemCount = [itemCountNumber integerValue];
    [self.cachesManager updateRowCount:itemCount section:section];
    return [itemCountNumber integerValue];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    [self registerCellClassIfNeed:collectionView reuseId:reuseId];
    MLNUICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    [cell pushContentViewWithLuaCore:self.mln_luaCore];
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
    [reuseCallback addIntArgument:(int)indexPath.item+1];
    [reuseCallback callIfCan];
    [cell requestLayoutIfNeed];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView longPressItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    MLNUIBlock *callback = [self longPressRowCallbackByReuseId:reuseId];
    
    UICollectionViewCell<MLNUIReuseCellProtocol> *cell = (UICollectionViewCell<MLNUIReuseCellProtocol> *)[collectionView cellForItemAtIndexPath:indexPath];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (callback) {
        [callback addLuaTableArgument:[cell getLuaTable]];
        [callback addIntArgument:(int)indexPath.section+1];
        [callback addIntArgument:(int)indexPath.row+1];
        [callback callIfCan];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    MLNUIBlock *callback = [self selectedRowCallbackByReuseId:reuseId];
    MLNUICollectionViewCell *cell = (MLNUICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (callback) {
        [callback addLuaTableArgument:[cell getLuaTable]];
        [callback addIntArgument:(int)indexPath.section+1];
        [callback addIntArgument:(int)indexPath.item+1];
        [callback callIfCan];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell<MLNUIReuseCellProtocol> *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    [cell updateLastReueseId:reuseId];
    MLNUIBlock *cellWillAppearCallback = [self cellWillAppearCallbackByReuseId:reuseId];
    if (cellWillAppearCallback) {
        MLNUIKitLuaAssert([cell isKindOfClass:[MLNUICollectionViewCell class]], @"Unkown type of cell");
        MLNUICollectionViewCell *cell_t = (MLNUICollectionViewCell *)cell;
        [cellWillAppearCallback addLuaTableArgument:[cell_t getLuaTable]];
        [cellWillAppearCallback addIntArgument:(int)indexPath.section+1];
        [cellWillAppearCallback addIntArgument:(int)indexPath.item+1];
        [cellWillAppearCallback callIfCan];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell<MLNUIReuseCellProtocol> *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = [cell lastReueseId];
    if (!(reuseId && reuseId.length > 0)) {
        reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    }
    MLNUIBlock *cellDidDisappearCallback = [self cellDidDisappearCallbackByReuseId:reuseId];
    if (cellDidDisappearCallback) {
        MLNUIKitLuaAssert([cell isKindOfClass:[MLNUICollectionViewCell class]], @"Unknow type of cell!");
        MLNUICollectionViewCell *cell_t = (MLNUICollectionViewCell *)cell;
        [cellDidDisappearCallback addLuaTableArgument:[cell_t getLuaTable]];
        [cellDidDisappearCallback addIntArgument:(int)indexPath.section+1];
        [cellDidDisappearCallback addIntArgument:(int)indexPath.item+1];
        [cellDidDisappearCallback callIfCan];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout & MLNUICollectionViewGridLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    MLNUIBlock *sizeForCellCallback = [self sizeForCellCallbackByReuseId:reuseId];
    if (!sizeForCellCallback) {
        if (!sizeForCellCallback) {
            if ([collectionView.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
                return ((UICollectionViewFlowLayout *)collectionViewLayout).itemSize;
            } else {
                return CGSizeZero;
            }
        }
    }
    NSUInteger section = indexPath.section;
    NSUInteger item = indexPath.item;
    // 1. cache
    NSValue *sizeValue = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (sizeValue) {
        CGSize size = [sizeValue CGSizeValue];
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            return size;
        }
    }
    // 2. call lua
    [sizeForCellCallback addIntArgument:(int)section+1];
    [sizeForCellCallback addIntArgument:(int)item+1];
    sizeValue = [sizeForCellCallback callIfCan];
    MLNUIKitLuaAssert(sizeValue && [sizeValue isKindOfClass:[NSValue class]] &&
              ![sizeValue isMemberOfClass:NSClassFromString(@"__NSCFBoolean")] &&
              ![sizeValue isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'sizeForCell/sizeForCellByReuseId' must be a Size!");
    MLNUIKitLuaAssert([sizeValue CGSizeValue].width > 0 && [sizeValue CGSizeValue].height > 0, @"The width and height of cell must greater than 0!");
    // 处理边界值
    sizeValue = [self handleCellBoundaryValueWithSize:[sizeValue CGSizeValue]];
    if (!sizeValue) {
        return CGSizeZero;
    }
    // 3. update cache
    [self.cachesManager updateLayoutInfo:sizeValue forIndexPath:indexPath];
    return [sizeValue CGSizeValue];
}

#pragma mark - Save UICollectionViewDataSource Callback
- (void)lua_numbersOfSections:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.sectionCountCallback = callback;
}

- (void)lua_numberOfRowsInSection:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.itemCountCallback = callback;
}

- (void)lua_reuseIdWithCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.cellReuseIdCallback = callback;
}

- (void)lua_initCellBy:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    if (reuseId && reuseId.length >0) {
        [self.initedCellCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_reuseCellBy:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    if (reuseId && reuseId.length >0) {
        [self.reuseCellCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_initCellCallback:(MLNUIBlock *)callback
{
    [self lua_initCellBy:kMLNUICollectionViewCellReuseID callback:callback];
}

- (void)lua_reuseCellCallback:(MLNUIBlock *)callback
{
    [self lua_reuseCellBy:kMLNUICollectionViewCellReuseID callback:callback];
}

#pragma mark - Save UICollectionViewDelegate Callback
- (void)lua_selectedRow:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.selectedRowCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_selectedRowCallback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    [self lua_selectedRow:kMLNUICollectionViewCellReuseID callback:callback];
}

- (void)lua_longPressRow:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.longPressRowCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_longPressRowCallback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    [self lua_longPressRow:kMLNUICollectionViewCellReuseID callback:callback];
}

- (void)lua_cellWillAppearCallback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    [self.cellWillAppearCallbacks setObject:callback forKey:kMLNUICollectionViewCellReuseID];
}

- (void)lua_cellDidDisappearCallback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    [self.cellDidDisappearCallbacks setObject:callback forKey:kMLNUICollectionViewCellReuseID];
}

- (void)lua_cellWillAppear:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    [self.cellWillAppearCallbacks setObject:callback forKey:reuseId];
}

- (void)lua_cellDidDisappear:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    [self.cellDidDisappearCallbacks setObject:callback forKey:reuseId];
}

- (void)lua_sizeForCellCallback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    [self lua_sizeForCellByReuseId:kMLNUICollectionViewCellReuseID callback:callback];
}

- (void)lua_sizeForCellByReuseId:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    [self.sizeForCellCallbacks setObject:callback forKey:reuseId];
}

#pragma mark -
- (NSValue *)handleCellBoundaryValueWithSize:(CGSize)size
{
    size.width = size.width < 0 ? 0 : size.width;
    size.height = size.height < 0 ? 0 : size.height;
    return [NSValue valueWithCGSize:size];
}

#pragma mark - Export For Lua
LUA_EXPORT_BEGIN(MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(sectionCount, "lua_numbersOfSections:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(rowCount, "lua_numberOfRowsInSection:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(reuseId, "lua_reuseIdWithCallback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(initCellByReuseId, "lua_initCellBy:callback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(fillCellDataByReuseId, "lua_reuseCellBy:callback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(initCell, "lua_initCellCallback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(fillCellData, "lua_reuseCellCallback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(selectedRowByReuseId, "lua_selectedRow:callback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(selectedRow, "lua_selectedRowCallback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(longPressRowByReuseId, "lua_longPressRow:callback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(longPressRow, "lua_longPressRowCallback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(sizeForCell, "lua_sizeForCellCallback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(sizeForCellByReuseId, "lua_sizeForCellByReuseId:callback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(cellWillAppear, "lua_cellWillAppearCallback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(cellDidDisappear, "lua_cellDidDisappearCallback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(cellWillAppearByReuseId, "lua_cellWillAppear:callback:", MLNUICollectionViewAdapter)
LUA_EXPORT_METHOD(cellDidDisappearByReuseId, "lua_cellDidDisappear:callback:", MLNUICollectionViewAdapter)
LUA_EXPORT_END(MLNUICollectionViewAdapter, CollectionViewAdapter, NO, NULL, NULL)

@end
