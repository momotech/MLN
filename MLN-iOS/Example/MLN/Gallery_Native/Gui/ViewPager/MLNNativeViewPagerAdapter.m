//
//  MLNNativeViewPagerAdapter.m
//  MLN
//
//  Created by MoMo on 2018/8/31.
//

#import "MLNNativeViewPagerAdapter.h"
#import "MLNKitHeader.h"
#import "MLNCollectionViewCell.h"
#import "MLNBlock.h"
#import "NSDictionary+MLNSafety.h"
#import "MLNNativeViewPagerCell.h"

static NSString *kMLNViewPageID = @"kMLNViewPageID";

@interface MLNNativeViewPagerAdapter()

@property (nonatomic, strong) MLNBlock *rowNumbersCallback;
@property (nonatomic, strong) MLNBlock *cellReuseIdCallback;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNBlock *> *initedCellCallbacks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNBlock *> *reuseCellCallbacks;
@property (nonatomic, strong) NSMutableSet<NSString *> *cellReuseIds;

//@property (nonatomic)

@end
@implementation MLNNativeViewPagerAdapter

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
    [self.targetCollectionView registerClass:[MLNNativeViewPagerCell class] forCellWithReuseIdentifier:kMLNViewPageID];
}

- (void)setRowNumbersCallback:(MLNBlock *)rowNumbersCallback
{
    _rowNumbersCallback = rowNumbersCallback;
}

- (NSString *)reuseIdAt:(NSIndexPath *)indexPath
{
    if (self.cellReuseIdCallback) {
        [self.cellReuseIdCallback addIntArgument:(int)indexPath.item+1];
        id ret = [self.cellReuseIdCallback callIfCan];
        MLNKitLuaAssert([ret isKindOfClass:[NSString class]], @"The reuse id must be a string!");
        return [ret length] > 0 ? ret : kMLNCollectionViewCellReuseID;
    }
    return kMLNCollectionViewCellReuseID;
}

- (void)registerCellClassIfNeed:(UICollectionView *)collectionView  reuseId:(NSString *)reuseId
{
    MLNKitLuaAssert(collectionView, @"collectionView view must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must be nil!");
    if (reuseId && ![self.cellReuseIds containsObject:reuseId]) {
        [collectionView registerClass:[MLNCollectionViewCell class] forCellWithReuseIdentifier:reuseId];
        [self.cellReuseIds addObject:reuseId];
    }
}

- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index
{
    return (int)index % self.cellCounts;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    NSInteger itemCount = 0;
//    if (self.rowNumbersCallback) {
//        [self.rowNumbersCallback addIntArgument:1];
//        itemCount = [[self.rowNumbersCallback callIfCan] integerValue];
//    }
//    _cellCounts = itemCount;
//    return [self.viewPager updateTotalItemCount:_cellCounts];
    return 2;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
//    NSString *reuseId = [self reuseIdAt:indexPath];
//    [self registerCellClassIfNeed:collectionView reuseId:reuseId];
//    MLNCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
////    [cell pushContentViewWithLuaCore:self.mln_luaCore];
//    if (!cell.isInited) {
//        MLNBlock *initCallback = [self.initedCellCallbacks objectForKey:reuseId];
//        MLNKitLuaAssert(initCallback, @"It must not be nil callback of cell init!");
//        [initCallback addLuaTableArgument:[cell getLuaTable]];
//        [initCallback addIntArgument:[self pageControlIndexWithCurrentCellIndex:indexPath.item] + 1];
//        [initCallback callIfCan];
//        [cell initCompleted];
//        if (indexPath.item == 0 && _viewPager.aheadLoad && indexPath.item + 1 < [collectionView numberOfItemsInSection:0]) {
//            [self collectionView:collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.item + 1 inSection:0]];
//        }
//    }
//    MLNBlock *reuseCallback = [self.reuseCellCallbacks objectForKey:reuseId];
//    MLNKitLuaAssert(reuseCallback, @"It must not be nil callback of cell reuse!");
//    [reuseCallback addLuaTableArgument:[cell getLuaTable]];
//    [reuseCallback addIntArgument:[self pageControlIndexWithCurrentCellIndex:indexPath.item] + 1];
//    [reuseCallback callIfCan];
//    [cell requestLayoutIfNeed];
//    return cell;
    
    
    MLNNativeViewPagerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMLNViewPageID forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor redColor];
    
    return cell;
}

#pragma mark -  Save Lua Callback
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
        [self.initedCellCallbacks mln_setObject:callback forKey:reuseId];
    }
}

- (void)lua_reuseCellBy:(NSString *)reuseId callback:(MLNBlock *)callback
{
    MLNKitLuaAssert(callback , @"The callback must not be nil!");
    MLNKitLuaAssert(reuseId && reuseId.length >0 , @"The reuse id must not be nil!");
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

//#pragma mark - Export For Lua
//LUA_EXPORT_BEGIN(MLNNativeViewPagerAdapter)
//LUA_EXPORT_METHOD(getCount, "lua_numberOfRowsInSection:", MLNNativeViewPagerAdapter)
//LUA_EXPORT_METHOD(reuseId, "lua_reuseIdWithCallback:", MLNNativeViewPagerAdapter)
//LUA_EXPORT_METHOD(initCellByReuseId, "lua_initCellBy:callback:", MLNNativeViewPagerAdapter)
//LUA_EXPORT_METHOD(fillCellDataByReuseId, "lua_reuseCellBy:callback:", MLNNativeViewPagerAdapter)
//LUA_EXPORT_METHOD(initCell, "lua_initCellCallback:", MLNNativeViewPagerAdapter)
//LUA_EXPORT_METHOD(fillCellData, "lua_reuseCellCallback:", MLNNativeViewPagerAdapter)
//LUA_EXPORT_END(MLNNativeViewPagerAdapter, ViewPagerAdapter, NO, NULL, NULL)

@end
