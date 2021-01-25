//
//  MLNUIViewPagerAdapter.m
//  MLNUI
//
//  Created by MoMo on 2018/8/31.
//

#import "MLNUIViewPagerAdapter.h"
#import "MLNUIKitHeader.h"
#import "MLNUIEntityExporterMacro.h"
#import "MLNUICollectionViewCell.h"
#import "MLNUIBlock.h"
#import "NSDictionary+MLNUISafety.h"

@interface MLNUIViewPagerAdapter()

@property (nonatomic, strong) MLNUIBlock *rowNumbersCallback;
@property (nonatomic, strong) MLNUIBlock *cellReuseIdCallback;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUIBlock *> *initedCellCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUIBlock *> *reuseCellCallbacks;
@property (nonatomic, strong) NSMutableSet<NSString *> *cellReuseIds;

@end
@implementation MLNUIViewPagerAdapter

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    _initedCellCallbacks = [NSMutableDictionary dictionary];
    _reuseCellCallbacks = [NSMutableDictionary dictionary];
    _cellReuseIds = [NSMutableSet set];
}

- (void)setRowNumbersCallback:(MLNUIBlock *)rowNumbersCallback
{
    _rowNumbersCallback = rowNumbersCallback;
}

- (NSString *)reuseIdAt:(NSIndexPath *)indexPath
{
    if (self.cellReuseIdCallback) {
        [self.cellReuseIdCallback addIntArgument:(int)indexPath.item+1];
        id ret = [self.cellReuseIdCallback callIfCan];
        MLNUIKitLuaAssert([ret isKindOfClass:[NSString class]], @"The reuse id must be a string!");
        return [ret length] > 0 ? ret : kMLNUICollectionViewCellReuseID;
    }
    return kMLNUICollectionViewCellReuseID;
}

- (void)registerCellClassIfNeed:(UICollectionView *)collectionView  reuseId:(NSString *)reuseId
{
    MLNUIKitLuaAssert(collectionView, @"collectionView view must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must be nil!");
    if (reuseId && ![self.cellReuseIds containsObject:reuseId]) {
        [collectionView registerClass:[MLNUICollectionViewCell class] forCellWithReuseIdentifier:reuseId];
        [self.cellReuseIds addObject:reuseId];
    }
}

- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index
{
    return (int)index % self.cellCounts;
}

// TODO: ViewPager 桥接类是否可移除？
- (void)prepareToUseCell:(__kindof MLNUICollectionViewCell *)cell {
    [cell createLuaTableAsCellNameForLuaIfNeed:self.mlnui_luaCore];
    [cell createLayoutNodeIfNeedWithFitSize:cell.frame.size maxSize:cell.frame.size];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger itemCount = 0;
    if (self.rowNumbersCallback) {
        [self.rowNumbersCallback addIntArgument:1];
        itemCount = [[self.rowNumbersCallback callIfCan] integerValue];
    }
    _cellCounts = itemCount;
    return [self.viewPager updateTotalItemCount:_cellCounts];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSString *reuseId = [self reuseIdAt:indexPath];
    [self registerCellClassIfNeed:collectionView reuseId:reuseId];
    MLNUICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    [self prepareToUseCell:cell];
    
    if (!cell.isInited) {
        MLNUIBlock *initCallback = [self.initedCellCallbacks objectForKey:reuseId];
        MLNUIKitLuaAssert(initCallback, @"It must not be nil callback of cell init!");
        [initCallback addLuaTableArgument:[cell getLuaTable]];
        [initCallback addIntArgument:[self pageControlIndexWithCurrentCellIndex:indexPath.item] + 1];
        [initCallback callIfCan];
        [cell initCompleted];
        if (indexPath.item == 0 && _viewPager.aheadLoad && indexPath.item + 1 < [collectionView numberOfItemsInSection:0]) {
            [self collectionView:collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.item + 1 inSection:0]];
        }
    }
    MLNUIBlock *reuseCallback = [self.reuseCellCallbacks objectForKey:reuseId];
    MLNUIKitLuaAssert(reuseCallback, @"It must not be nil callback of cell reuse!");
    [reuseCallback addLuaTableArgument:[cell getLuaTable]];
    [reuseCallback addIntArgument:[self pageControlIndexWithCurrentCellIndex:indexPath.item] + 1];
    [reuseCallback callIfCan];
    [cell mlnui_requestLayoutIfNeed];
    return cell;
}

#pragma mark -  Save Lua Callback
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
        [self.initedCellCallbacks mlnui_setObject:callback forKey:reuseId];
    }
}

- (void)luaui_reuseCellBy:(NSString *)reuseId callback:(MLNUIBlock *)callback
{
    MLNUIKitLuaAssert(callback , @"The callback must not be nil!");
    MLNUIKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
    if (reuseId && reuseId.length >0) {
        [self.reuseCellCallbacks mlnui_setObject:callback forKey:reuseId];
    }
}

- (void)luaui_initCellCallback:(MLNUIBlock *)callback
{
    [self luaui_initCellBy:kMLNUICollectionViewCellReuseID callback:callback];
}

- (void)luaui_reuseCellCallback:(MLNUIBlock *)callback
{
    [self luaui_reuseCellBy:kMLNUICollectionViewCellReuseID callback:callback];
}

#pragma mark - Export For Lua
LUAUI_EXPORT_BEGIN(MLNUIViewPagerAdapter)
LUAUI_EXPORT_METHOD(getCount, "luaui_numberOfRowsInSection:", MLNUIViewPagerAdapter)
LUAUI_EXPORT_METHOD(reuseId, "luaui_reuseIdWithCallback:", MLNUIViewPagerAdapter)
LUAUI_EXPORT_METHOD(initCellByReuseId, "luaui_initCellBy:callback:", MLNUIViewPagerAdapter)
LUAUI_EXPORT_METHOD(fillCellDataByReuseId, "luaui_reuseCellBy:callback:", MLNUIViewPagerAdapter)
LUAUI_EXPORT_METHOD(initCell, "luaui_initCellCallback:", MLNUIViewPagerAdapter)
LUAUI_EXPORT_METHOD(fillCellData, "luaui_reuseCellCallback:", MLNUIViewPagerAdapter)
LUAUI_EXPORT_END(MLNUIViewPagerAdapter, ViewPagerAdapter, NO, NULL, NULL)

@end
