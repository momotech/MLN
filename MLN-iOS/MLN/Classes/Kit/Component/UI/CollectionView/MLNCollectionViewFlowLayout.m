//
//  MLNCollectionViewFlowLayout.m
//  
//
//  Created by MoMo on 2018/7/17.
//  
//

#import "MLNCollectionViewFlowLayout.h"
#import "MLNKitHeader.h"
#import "MLNViewExporterMacro.h"

@implementation MLNCollectionViewFlowLayout

-(void)lua_setItemSize:(CGFloat)width height:(CGFloat)height
{
    self.itemSize = CGSizeMake(width, height);
}

- (void)lua_setMinimumLineSpacing:(CGFloat)minimumLineSpacing
{
    [self setMinimumLineSpacing:minimumLineSpacing];
    UIEdgeInsets insets = self.sectionInset;
    insets.top = minimumLineSpacing;
    insets.bottom = minimumLineSpacing;
    self.sectionInset = insets;
}

- (void)lua_setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing
{
    [self setMinimumInteritemSpacing:minimumInteritemSpacing];
    UIEdgeInsets insets = self.sectionInset;
    insets.left = minimumInteritemSpacing;
    insets.right = minimumInteritemSpacing;
    self.sectionInset = insets;
}

- (void)relayoutIfNeed
{
    // @note: CollectionView 对于layout调用了此方法，此处空实现
}

#pragma mark - Export For Lua
LUA_EXPORT_BEGIN(MLNCollectionViewFlowLayout)
LUA_EXPORT_PROPERTY(lineSpacing, "lua_setMinimumLineSpacing:","minimumLineSpacing", MLNCollectionViewFlowLayout)
LUA_EXPORT_PROPERTY(itemSpacing, "lua_setMinimumInteritemSpacing:","minimumInteritemSpacing", MLNCollectionViewFlowLayout)
LUA_EXPORT_PROPERTY(itemSize, "setItemSize:","itemSize", MLNCollectionViewFlowLayout)
LUA_EXPORT_END(MLNCollectionViewFlowLayout, CollectionViewLayout, NO, NULL, NULL)

@end
