//
//  MLNCollectionViewAdapter.m
//  
//
//  Created by MoMo on 2018/7/9.
//

#import "MLNCollectionViewAdapter.h"
#import "MLNKitHeader.h"
#import "MLNViewExporterMacro.h"
#import "MLNCollectionViewCell.h"
#import "MLNBlock.h"
#import "NSDictionary+MLNSafety.h"


#define kReuseIndentifierPlaceholder @"kReuseIndentifierPlaceholder"

@interface MLNCollectionViewAdapter()

@property (nonatomic, strong) MLNBlock *sectionCountCallback;
@property (nonatomic, strong) MLNBlock *itemCountCallback;
@property (nonatomic, strong) MLNBlock *cellReuseIdCallback;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNBlock *> *selectedRowCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNBlock *> *longPressRowCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNBlock *> *sizeForCellCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNBlock *> *cellWillAppearCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNBlock *> *cellDidDisappearCallbacks;


@end

@implementation MLNCollectionViewAdapter

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
        _cachesManager = [[MLNAdapterCachesManager alloc] init];
    }
    return self;
}

- (void)registerCellClassIfNeed:(UICollectionView *)collectionView  reuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(collectionView, @"collectionView view must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length > 0 , @"The reuse id must not be nil!");
    
    NSMutableDictionary* classDict = [self collectionViewRegisterCellClassDict:collectionView];
    if (reuseId && reuseId.length > 0 && ![classDict valueForKey:reuseId]) {
        [collectionView registerClass:[MLNCollectionViewCell class] forCellWithReuseIdentifier:reuseId];
        //[self.cellReuseIds addObject:reuseId];
    }
}

- (NSMutableDictionary *)collectionViewRegisterCellClassDict:(UICollectionView*)collectionView {
    return [collectionView valueForKey:@"_cellClassDict"];
}

#pragma mark - MLNCollectionViewAdapterProtocol
@synthesize collectionView;
- (NSString *)reuseIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.cellReuseIdCallback) {
        return kMLNCollectionViewCellReuseID;
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
        return kMLNCollectionViewCellReuseID;
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
        initCellCallback = [self.initedCellCallbacks objectForKey:kMLNCollectionViewCellReuseID];
    }
    
    return initCellCallback;
}

- (MLNBlock *)fillCellDataCallbackByReuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNBlock *fillCellDataCallback = [self.reuseCellCallbacks objectForKey:reuseId];
    if (!fillCellDataCallback) {
        fillCellDataCallback = [self.reuseCellCallbacks objectForKey:kMLNCollectionViewCellReuseID];
    }
    
    return fillCellDataCallback;
}

- (MLNBlock *)sizeForCellCallbackByReuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNBlock *sizeForCellCallback = [self.sizeForCellCallbacks objectForKey:reuseId];
    if (!sizeForCellCallback) {
        sizeForCellCallback = [self.sizeForCellCallbacks objectForKey:kMLNCollectionViewCellReuseID];
    }
    
    return sizeForCellCallback;
}

- (MLNBlock *)cellWillAppearCallbackByReuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNBlock *cellWillAppearCallback = [self.cellWillAppearCallbacks objectForKey:reuseId];
    if (!cellWillAppearCallback) {
        cellWillAppearCallback = [self.cellWillAppearCallbacks objectForKey:kMLNCollectionViewCellReuseID];
    }
    
    return cellWillAppearCallback;
}

- (MLNBlock *)cellDidDisappearCallbackByReuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNBlock *cellDidDisappearCallback = [self.cellDidDisappearCallbacks objectForKey:reuseId];
    if (!cellDidDisappearCallback) {
        cellDidDisappearCallback = [self.cellDidDisappearCallbacks objectForKey:kMLNCollectionViewCellReuseID];
    }
    return cellDidDisappearCallback;
}

- (MLNBlock *)selectedRowCallbackByReuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNBlock *selectRowCallback = [self.selectedRowCallbacks objectForKey:reuseId];
    if (!selectRowCallback) {
        selectRowCallback = [self.selectedRowCallbacks objectForKey:kMLNCollectionViewCellReuseID];
    }
    return selectRowCallback;
}

- (MLNBlock *)longPressRowCallbackByReuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNBlock *longPressRowCallback = [self.longPressRowCallbacks objectForKey:reuseId];
    if (!longPressRowCallback) {
        longPressRowCallback = [self.longPressRowCallbacks objectForKey:kMLNCollectionViewCellReuseID];
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
    MLNKitLuaAssert(numbers && [numbers isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'sectionCount' must be a number!");
    MLNKitLuaAssert([numbers integerValue] > 0, @"The return value of method 'sectionCount' must greater than 0!");
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
    MLNKitLuaAssert(itemCountNumber && [itemCountNumber isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'rowCount' must be a number!");
    // 3. update cache
    itemCount = [itemCountNumber integerValue];
    [self.cachesManager updateRowCount:itemCount section:section];
    return [itemCountNumber integerValue];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    [self registerCellClassIfNeed:collectionView reuseId:reuseId];
    MLNCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
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
    [reuseCallback addIntArgument:(int)indexPath.item+1];
    [reuseCallback callIfCan];
    [cell requestLayoutIfNeed];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView longPressItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    MLNBlock *callback = [self longPressRowCallbackByReuseId:reuseId];
    
    UICollectionViewCell<MLNReuseCellProtocol> *cell = (UICollectionViewCell<MLNReuseCellProtocol> *)[collectionView cellForItemAtIndexPath:indexPath];
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
    MLNBlock *callback = [self selectedRowCallbackByReuseId:reuseId];
    MLNCollectionViewCell *cell = (MLNCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (callback) {
        [callback addLuaTableArgument:[cell getLuaTable]];
        [callback addIntArgument:(int)indexPath.section+1];
        [callback addIntArgument:(int)indexPath.item+1];
        [callback callIfCan];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell<MLNReuseCellProtocol> *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    [cell updateLastReueseId:reuseId];
    MLNBlock *cellWillAppearCallback = [self cellWillAppearCallbackByReuseId:reuseId];
    if (cellWillAppearCallback) {
        MLNKitLuaAssert([cell isKindOfClass:[MLNCollectionViewCell class]], @"Unkown type of cell");
        MLNCollectionViewCell *cell_t = (MLNCollectionViewCell *)cell;
        [cellWillAppearCallback addLuaTableArgument:[cell_t getLuaTable]];
        [cellWillAppearCallback addIntArgument:(int)indexPath.section+1];
        [cellWillAppearCallback addIntArgument:(int)indexPath.item+1];
        [cellWillAppearCallback callIfCan];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell<MLNReuseCellProtocol> *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = [cell lastReueseId];
    if (!(reuseId && reuseId.length > 0)) {
        reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    }
    MLNBlock *cellDidDisappearCallback = [self cellDidDisappearCallbackByReuseId:reuseId];
    if (cellDidDisappearCallback) {
        MLNKitLuaAssert([cell isKindOfClass:[MLNCollectionViewCell class]], @"Unknow type of cell!");
        MLNCollectionViewCell *cell_t = (MLNCollectionViewCell *)cell;
        [cellDidDisappearCallback addLuaTableArgument:[cell_t getLuaTable]];
        [cellDidDisappearCallback addIntArgument:(int)indexPath.section+1];
        [cellDidDisappearCallback addIntArgument:(int)indexPath.item+1];
        [cellDidDisappearCallback callIfCan];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout & MLNCollectionViewGridLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    MLNBlock *sizeForCellCallback = [self sizeForCellCallbackByReuseId:reuseId];
    if (!sizeForCellCallback) {
        if (!sizeForCellCallback) {
            if ([collectionView.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
                return ((UICollectionViewFlowLayout *)collectionView.collectionViewLayout).itemSize;
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
    MLNKitLuaAssert(sizeValue && [sizeValue isKindOfClass:[NSValue class]] &&
              ![sizeValue isMemberOfClass:NSClassFromString(@"__NSCFBoolean")] &&
              ![sizeValue isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'sizeForCell/sizeForCellByReuseId' must be a Size!");
    MLNKitLuaAssert([sizeValue CGSizeValue].width > 0 && [sizeValue CGSizeValue].height > 0, @"The width and height of cell must greater than 0!");
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
- (void)lua_numbersOfSections:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock);
    self.sectionCountCallback = callback;
}

- (void)lua_numberOfRowsInSection:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock);
    self.itemCountCallback = callback;
}

- (void)lua_reuseIdWithCallback:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock);
    self.cellReuseIdCallback = callback;
}

- (void)lua_initCellBy:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock);
    if (reuseId && reuseId.length >0) {
        [self.initedCellCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_reuseCellBy:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock);
    if (reuseId && reuseId.length >0) {
        [self.reuseCellCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_initCellCallback:(MLNBlock *)callback
{
    [self lua_initCellBy:kMLNCollectionViewCellReuseID callback:callback];
}

- (void)lua_reuseCellCallback:(MLNBlock *)callback
{
    [self lua_reuseCellBy:kMLNCollectionViewCellReuseID callback:callback];
}

#pragma mark - Save UICollectionViewDelegate Callback
- (void)lua_selectedRow:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.selectedRowCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_selectedRowCallback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    [self lua_selectedRow:kMLNCollectionViewCellReuseID callback:callback];
}

- (void)lua_longPressRow:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.longPressRowCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_longPressRowCallback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    [self lua_longPressRow:kMLNCollectionViewCellReuseID callback:callback];
}

- (void)lua_cellWillAppearCallback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    [self.cellWillAppearCallbacks setObject:callback forKey:kMLNCollectionViewCellReuseID];
}

- (void)lua_cellDidDisappearCallback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    [self.cellDidDisappearCallbacks setObject:callback forKey:kMLNCollectionViewCellReuseID];
}

- (void)lua_cellWillAppear:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    [self.cellWillAppearCallbacks setObject:callback forKey:reuseId];
}

- (void)lua_cellDidDisappear:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    [self.cellDidDisappearCallbacks setObject:callback forKey:reuseId];
}

- (void)lua_sizeForCellCallback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    [self lua_sizeForCellByReuseId:kMLNCollectionViewCellReuseID callback:callback];
}

- (void)lua_sizeForCellByReuseId:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
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
LUA_EXPORT_BEGIN(MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(sectionCount, "lua_numbersOfSections:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(rowCount, "lua_numberOfRowsInSection:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(reuseId, "lua_reuseIdWithCallback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(initCellByReuseId, "lua_initCellBy:callback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(fillCellDataByReuseId, "lua_reuseCellBy:callback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(initCell, "lua_initCellCallback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(fillCellData, "lua_reuseCellCallback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(selectedRowByReuseId, "lua_selectedRow:callback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(selectedRow, "lua_selectedRowCallback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(longPressRowByReuseId, "lua_longPressRow:callback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(longPressRow, "lua_longPressRowCallback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(sizeForCell, "lua_sizeForCellCallback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(sizeForCellByReuseId, "lua_sizeForCellByReuseId:callback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(cellWillAppear, "lua_cellWillAppearCallback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(cellDidDisappear, "lua_cellDidDisappearCallback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(cellWillAppearByReuseId, "lua_cellWillAppear:callback:", MLNCollectionViewAdapter)
LUA_EXPORT_METHOD(cellDidDisappearByReuseId, "lua_cellDidDisappear:callback:", MLNCollectionViewAdapter)
LUA_EXPORT_END(MLNCollectionViewAdapter, CollectionViewAdapter, NO, NULL, NULL)

@end
