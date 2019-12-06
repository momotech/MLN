//
//  MLNCollectionViewGridLayoutFix.m
//  MLN
//
//  Created by MoMo on 2019/11/1.
//

#import "MLNCollectionViewGridLayoutFix.h"
#import "MLNViewExporterMacro.h"

@implementation MLNCollectionViewGridLayoutFix

#pragma mark - Export For Lua
LUA_EXPORT_BEGIN(MLNCollectionViewGridLayoutFix)
LUA_EXPORT_PROPERTY(lineSpacing, "lua_setLineSpacing:","lua_lineSpacing", MLNCollectionViewGridLayoutFix)
LUA_EXPORT_PROPERTY(itemSpacing, "lua_setItemSpacing:","lua_itemSpacing", MLNCollectionViewGridLayoutFix)
LUA_EXPORT_PROPERTY(spanCount, "lua_setSpanCount:","lua_spanCount", MLNCollectionViewGridLayoutFix)
LUA_EXPORT_METHOD(layoutInset, "lua_setlayoutInset:left:bottom:right:", MLNCollectionViewGridLayoutFix)
LUA_EXPORT_END(MLNCollectionViewGridLayoutFix, CollectionViewGridLayoutFix, NO, NULL, NULL)

@end
