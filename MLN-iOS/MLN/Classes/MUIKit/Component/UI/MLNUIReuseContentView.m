//
//  MLNUIReuseContentView.m
//
//
//  Created by MoMo on 2018/11/12.
//

#import "MLNUIReuseContentView.h"
#import "MLNUILuaCore.h"
#import "MLNUIKitHeader.h"
#import "UIView+MLNUIKit.h"
#import "UIView+MLNUILayout.h"
#import "MLNUILayoutContainerNode.h"
#import "MLNUILuaTable.h"

@interface MLNUIReuseContentView()

@property (nonatomic, weak) UIView<MLNUIReuseCellProtocol> *cell;

@end

@implementation MLNUIReuseContentView

- (instancetype)initWithFrame:(CGRect)frame cellView:(UIView<MLNUIReuseCellProtocol> *)cell
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _cell = cell;
    }
    return self;
}

#pragma mark - Calculate Layout
- (CGFloat)calculHeightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight
{
    __unsafe_unretained MLNUILayoutNode *node = self.lua_node;
    node.enable = YES;
    node.heightType = MLNUILayoutMeasurementTypeWrapContent;
    [node changeWidth:width];
    node.maxHeight = maxHeight;
    CGSize cellSize = [node measureSizeWithMaxWidth:width maxHeight:maxHeight];
    node.heightType = MLNUILayoutMeasurementTypeIdle;
    [node changeHeight:cellSize.height];
    node.enable = NO;
    return cellSize.height;
}

- (CGSize)calculSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    __unsafe_unretained MLNUILayoutNode *node = self.lua_node;
    node.enable = YES;
    [node needLayoutAndSpread];
    node.heightType = MLNUILayoutMeasurementTypeWrapContent;
    node.widthType = MLNUILayoutMeasurementTypeWrapContent;
    node.maxWidth = maxWidth;
    node.maxHeight = maxHeight;
    CGSize cellSize = [node measureSizeWithMaxWidth:maxWidth maxHeight:maxHeight];
    node.heightType = MLNUILayoutMeasurementTypeIdle;
    node.widthType = MLNUILayoutMeasurementTypeIdle;
    node.enable = NO;
    return cellSize;
}

#pragma mark - Lua Table
- (void)pushToLuaCore:(MLNUILuaCore *)luaCore
{
    [self createLuaTableIfNeed:luaCore];
    [self setupLayoutNodeIfNeed];
    [self updateFrameIfNeed];
}

- (void)createLuaTableIfNeed:(MLNUILuaCore *)luaCore
{
    if (!_luaTable) {
        [self createLuaTableWithLuaCore:luaCore];
    }
}

- (void)setupLayoutNodeIfNeed
{
    if (!self.inited) {
        __unsafe_unretained MLNUILayoutContainerNode *node = (MLNUILayoutContainerNode *)self.lua_node;
        node.widthType = MLNUILayoutMeasurementTypeIdle;
        node.heightType = MLNUILayoutMeasurementTypeIdle;
        node.root = YES;
        node.enable = NO;
        [MLNUI_KIT_INSTANCE(self.mln_luaCore) addRootnode:node];
    }
}

- (void)createLuaTableWithLuaCore:(MLNUILuaCore *)luaCore
{
    _luaTable = [[MLNUILuaTable alloc] initWithLuaCore:luaCore env:MLNUILuaTableEnvRegister];
    [_luaTable setObject:self key:@"contentView"];
}

- (void)updateFrameIfNeed
{
    if (!CGSizeEqualToSize(self.frame.size, self.cell.bounds.size)) {
        CGRect frame = self.cell.bounds;
        MLNUILayoutNode *node = self.lua_node;
        [node changeX:frame.origin.x];
        [node changeY:frame.origin.y];
        [node changeWidth:frame.size.width];
        [node changeHeight:frame.size.height];
    }
}

#pragma mark - Override Method For Lua
- (void)lua_setCornerRadius:(CGFloat)cornerRadius
{
    if (self.cell) {
        [self.cell lua_setCornerRadius:cornerRadius];
        [self.cell.contentView lua_setCornerRadius:cornerRadius];
    }
    [super lua_setCornerRadius:cornerRadius];
}

- (void)setLua_marginTop:(CGFloat)lua_marginTop
{
    MLNUIKitLuaAssert(lua_marginTop == 0, @"The contentView should not called marginTop");
}

- (void)setLua_marginLeft:(CGFloat)lua_marginLeft
{
    MLNUIKitLuaAssert(lua_marginLeft == 0, @"The contentView should not called marginLeft");
}

- (void)setLua_marginRight:(CGFloat)lua_marginRight
{
    MLNUIKitLuaAssert(lua_marginRight == 0, @"The contentView should not called marginRight");
}

- (void)setLua_marginBottom:(CGFloat)lua_marginBottom
{
    MLNUIKitLuaAssert(lua_marginBottom == 0, @"The contentView should not called marginBottom");
}



@end
