//
//  MLNReuseContentView.m
//
//
//  Created by MoMo on 2018/11/12.
//

#import "MLNReuseContentView.h"
#import "MLNLuaCore.h"
#import "MLNKitHeader.h"
#import "UIView+MLNKit.h"
#import "UIView+MLNLayout.h"
#import "MLNLayoutContainerNode.h"
#import "MLNLuaTable.h"

@interface MLNReuseContentView()

@property (nonatomic, weak) UIView<MLNReuseCellProtocol> *cell;

@end

@implementation MLNReuseContentView

- (instancetype)initWithFrame:(CGRect)frame cellView:(UIView<MLNReuseCellProtocol> *)cell
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
    __unsafe_unretained MLNLayoutNode *node = self.lua_node;
    node.enable = YES;
    node.heightType = MLNLayoutMeasurementTypeWrapContent;
    [node changeWidth:width];
    node.maxHeight = maxHeight;
    CGSize cellSize = [node measureSizeWithMaxWidth:width maxHeight:maxHeight];
    node.heightType = MLNLayoutMeasurementTypeIdle;
    [node changeHeight:cellSize.height];
    node.enable = NO;
    return cellSize.height;
}

- (CGSize)calculSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    __unsafe_unretained MLNLayoutNode *node = self.lua_node;
    node.enable = YES;
    [node needLayoutAndSpread];
    node.heightType = MLNLayoutMeasurementTypeWrapContent;
    node.widthType = MLNLayoutMeasurementTypeWrapContent;
    node.maxWidth = maxWidth;
    node.maxHeight = maxHeight;
    CGSize cellSize = [node measureSizeWithMaxWidth:maxWidth maxHeight:maxHeight];
    node.heightType = MLNLayoutMeasurementTypeIdle;
    node.widthType = MLNLayoutMeasurementTypeIdle;
    node.enable = NO;
    return cellSize;
}

#pragma mark - Lua Table
- (void)pushToLuaCore:(MLNLuaCore *)luaCore
{
    [self createLuaTableIfNeed:luaCore];
    [self setupLayoutNodeIfNeed];
    [self updateFrameIfNeed];
}

- (void)createLuaTableIfNeed:(MLNLuaCore *)luaCore
{
    if (!_luaTable) {
        [self createLuaTableWithLuaCore:luaCore];
    }
}

- (void)setupLayoutNodeIfNeed
{
    if (!self.inited) {
        __unsafe_unretained MLNLayoutContainerNode *node = (MLNLayoutContainerNode *)self.lua_node;
        node.widthType = MLNLayoutMeasurementTypeIdle;
        node.heightType = MLNLayoutMeasurementTypeIdle;
        node.root = YES;
        node.enable = NO;
        [MLN_KIT_INSTANCE(self.mln_luaCore) addRootnode:node];
    }
}

- (void)createLuaTableWithLuaCore:(MLNLuaCore *)luaCore
{
    _luaTable = [[MLNLuaTable alloc] initWithLuaCore:luaCore env:MLNLuaTableEnvRegister];
    [_luaTable setObject:self key:@"contentView"];
}

- (void)updateFrameIfNeed
{
    if (!CGSizeEqualToSize(self.frame.size, self.cell.bounds.size)) {
        CGRect frame = self.cell.bounds;
        MLNLayoutNode *node = self.lua_node;
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
    MLNKitLuaAssert(lua_marginTop == 0, @"The contentView should not called marginTop");
}

- (void)setLua_marginLeft:(CGFloat)lua_marginLeft
{
    MLNKitLuaAssert(lua_marginLeft == 0, @"The contentView should not called marginLeft");
}

- (void)setLua_marginRight:(CGFloat)lua_marginRight
{
    MLNKitLuaAssert(lua_marginRight == 0, @"The contentView should not called marginRight");
}

- (void)setLua_marginBottom:(CGFloat)lua_marginBottom
{
    MLNKitLuaAssert(lua_marginBottom == 0, @"The contentView should not called marginBottom");
}



@end
