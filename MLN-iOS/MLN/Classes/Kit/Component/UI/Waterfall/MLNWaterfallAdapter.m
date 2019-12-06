//
//  MLNWaterfallAdapter.m
//  
//
//  Created by MoMo on 2018/7/18.
//

#import "MLNWaterfallAdapter.h"
#import "MLNWaterfallView.h"
#import "MLNCollectionViewCell.h"
#import "MLNInternalWaterfallView.h"
#import "MLNWaterfallHeaderView.h"
#import "MLNBlock.h"
#import "MLNKitHeader.h"
#import "MLNViewExporterMacro.h"
#import "UIView+MLNLayout.h"
#import "MLNLayoutNode.h"


#define kMLNWaterfallViewReuseID @"kMLNWaterfallViewReuseID"

@interface MLNWaterfallAdapter ()

@property (nonatomic, strong) MLNBlock *heightForHeaderCallback;
@property (nonatomic, strong) MLNBlock *headerValidCallback;
@property (nonatomic, strong) MLNBlock *initedHeaderCallback;
@property (nonatomic, strong) MLNBlock *reuseHeaderCallback;
@property (nonatomic, strong) MLNBlock *heightForCellCallback;
@property (nonatomic, strong) MLNBlock *headerWillAppearCallback;
@property (nonatomic, strong) MLNBlock *headerDidDisappearCallback;

@end

@implementation MLNWaterfallAdapter

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.heightForCellCallback) {
        [self.heightForCellCallback addIntArgument:(int)indexPath.section+1];
        [self.heightForCellCallback addIntArgument:(int)indexPath.item+1];
        NSNumber *heightValue = [self.heightForCellCallback callIfCan];
        MLNKitLuaAssert(heightValue && [heightValue isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'heightForCell' must be a number!");
        CGFloat height = CGFloatValueFromNumber(heightValue);
        height = height < 0 ? 0 : height;
        return height;
    }
    return 60.f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section != 0) { // WaterfallView 限制只有一个headerView
        return CGSizeMake(0, 0);
    }
    
    UIView *headerView = [MLNInternalWaterfallView headerViewInWaterfall:collectionView];
    if (!headerView) { // headerView 不存在，使用header新接口initedHeader、fillHeaderData、heightForHeader
        BOOL isHeaderValid = [self _mln_in_headerIsValid];
        if (section == 0 && isHeaderValid) {
            if (!self.heightForHeaderCallback) {
                MLNKitLuaAssert(NO, @"The 'heightForHeader' callback must not be nil!");
                return CGSizeZero;
            } else {
                [self.heightForHeaderCallback addIntArgument:(int)section+1];
                NSNumber *heightValue = [self.heightForHeaderCallback callIfCan];
                MLNKitLuaAssert(heightValue && [heightValue isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'heightForHeader' must be a number!");
                CGFloat height = CGFloatValueFromNumber(heightValue);
                height = height < 0 ? 0 : height;
                return CGSizeMake(0, height);
            }
        }
        return CGSizeZero;
    } else {
        CGSize size = [headerView.lua_node measureSizeWithMaxWidth:collectionView.frame.size.width maxHeight:CGFLOAT_MAX];
        return CGSizeMake(0, size.height);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UIView *headerView = [MLNInternalWaterfallView headerViewInWaterfall:collectionView];
    if (!headerView) {
        [collectionView registerClass:[MLNWaterfallHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMLNWaterfallHeaderViewReuseID];
        MLNWaterfallHeaderView *waterfallHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMLNWaterfallHeaderViewReuseID forIndexPath:indexPath];
        [waterfallHeaderView pushContentViewWithLuaCore:self.mln_luaCore];
        
        BOOL isHeaderValid = [self _mln_in_headerIsValid];
        if (indexPath.section != 0 || !isHeaderValid) {
            return waterfallHeaderView;
        }
        
        if (!waterfallHeaderView.isInited) {
            MLNKitLuaAssert(self.initedHeaderCallback, @"It must not be nil callback of header init!");
            [self.initedHeaderCallback addLuaTableArgument:[waterfallHeaderView getLuaTable]];
            [self.initedHeaderCallback addIntArgument:(int)indexPath.section+1];
            [self.initedHeaderCallback addIntArgument:(int)indexPath.row+1];
            [self.initedHeaderCallback callIfCan];
            [waterfallHeaderView initCompleted];
        }
        MLNKitLuaAssert(self.reuseHeaderCallback, @"It must not be nil callback of header reuse!")
        [self.reuseHeaderCallback addLuaTableArgument:[waterfallHeaderView getLuaTable]];
        [self.reuseHeaderCallback addIntArgument:(int)indexPath.section+1];
        [self.reuseHeaderCallback addIntArgument:(int)indexPath.row+1];
        [self.reuseHeaderCallback callIfCan];
        [waterfallHeaderView requestLayoutIfNeed];
        return waterfallHeaderView;
    } else {
        static NSString *reuseId = kMLNWaterfallViewReuseID;
        [collectionView registerClass:[MLNCollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseId];
        MLNCollectionViewCell *headerContentView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseId forIndexPath:indexPath];
        [headerContentView pushContentViewWithLuaCore:self.mln_luaCore];
        if ([collectionView isKindOfClass:[MLNInternalWaterfallView class]]) {
            [headerContentView setupLayoutNodeIfNeed];
            [headerContentView lua_addSubview:headerView];
            [headerView.lua_node needLayoutAndSpread];
            [headerContentView requestLayoutIfNeed];
            [headerContentView updateLuaContentViewIfNeed];
            headerContentView.bounds = headerContentView.bounds;
            return headerContentView;
        }
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if (self.headerWillAppearCallback) {
        id<MLNReuseCellProtocol> headerContentView = (id<MLNReuseCellProtocol>)view;
        [self.headerWillAppearCallback addLuaTableArgument:[headerContentView getLuaTable]];
        [self.headerWillAppearCallback addIntArgument:(int)indexPath.section+1];
        [self.headerWillAppearCallback addIntArgument:(int)indexPath.item+1];
        [self.headerWillAppearCallback callIfCan];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(nonnull UICollectionReusableView *)view forElementOfKind:(nonnull NSString *)elementKind atIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (self.headerDidDisappearCallback) {
        id<MLNReuseCellProtocol> headerContentView = (id<MLNReuseCellProtocol>)view;
        [self.headerDidDisappearCallback addLuaTableArgument:[headerContentView getLuaTable]];
        [self.headerDidDisappearCallback addIntArgument:(int)indexPath.section+1];
        [self.headerDidDisappearCallback addIntArgument:(int)indexPath.item+1];
        [self.headerDidDisappearCallback callIfCan];
    }
}

- (void)lua_headerWillAppearCallback:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock);
    self.headerWillAppearCallback = callback;
}

- (void)lua_headerDidDisappearCallback:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock);
    self.headerDidDisappearCallback = callback;
}

#pragma mark - WaterfallView header
- (void)lua_initHeaderCallback:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock);
    self.initedHeaderCallback = callback;
}

- (void)lua_reuseHeaderCallback:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock);
    self.reuseHeaderCallback = callback;
}

- (void)lua_headValidCallback:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock);
    self.headerValidCallback = callback;
}

#pragma mark - WaterfallViewLayoutDelegate
- (BOOL)headerIsValidWithWaterfallView:(UICollectionView *)waterfallView
{
    return [self _mln_in_headerIsValid];
}

- (BOOL)headerIsSettingInNewWayWithWaterfallView:(UICollectionView *)waterfallView
{
    return self.headerValidCallback? YES : NO;
}

#pragma mark - Private method
- (BOOL)_mln_in_headerIsValid
{
    if (!self.headerValidCallback) {
        return NO;
    }
    NSNumber *headerValidValue = [self.headerValidCallback callIfCan];
    MLNKitLuaAssert(headerValidValue && [headerValidValue isMemberOfClass:NSClassFromString(@"__NSCFBoolean")], @"The return value of  method 'headerValid' must be a bool value!");
    return [headerValidValue boolValue];
}

LUA_EXPORT_BEGIN(MLNWaterfallAdapter)
LUA_EXPORT_METHOD(heightForHeader, "setHeightForHeaderCallback:", MLNWaterfallAdapter)
LUA_EXPORT_METHOD(initHeader, "lua_initHeaderCallback:", MLNWaterfallAdapter)
LUA_EXPORT_METHOD(fillHeaderData, "lua_reuseHeaderCallback:", MLNWaterfallAdapter)
LUA_EXPORT_METHOD(headerValid, "lua_headValidCallback:", MLNWaterfallAdapter)
LUA_EXPORT_METHOD(heightForCell, "setHeightForCellCallback:", MLNWaterfallAdapter)
LUA_EXPORT_METHOD(headerWillAppear, "lua_headerWillAppearCallback:", MLNWaterfallAdapter)
LUA_EXPORT_METHOD(headerDidDisappear, "lua_headerDidDisappearCallback:", MLNWaterfallAdapter)
LUA_EXPORT_END(MLNWaterfallAdapter, WaterfallAdapter, YES, "MLNCollectionViewAdapter", NULL)

@end
