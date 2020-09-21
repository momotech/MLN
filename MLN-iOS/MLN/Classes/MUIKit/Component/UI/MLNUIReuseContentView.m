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
#import "MLNUILuaTable.h"

@interface MLNUIReuseContentView()

@property (nonatomic, weak) UIView<MLNUIReuseCellProtocol> *cell;
@property (nonatomic, assign) CGRect oldFrame; // the frame which before MLNUIReuseContentView's content layout change.

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

static inline void MLNUILayoutNodeClearWidth(UIView *view) {
    view.mlnui_layoutNode.width = MLNUIValueAuto; // 若要计算自适应宽度，需要清除之前已设置的宽度，否则计算出的是固定宽度
}

static inline void MLNUILayoutNodeClearHeight(UIView *view) {
    view.mlnui_layoutNode.height = MLNUIValueAuto; // 若要计算自适应高度，需要清除之前已设置的高度，否则计算出的是固定高度
}

- (CGFloat)calculHeightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight {
//    MLNUILayoutNodeClearHeight(self);
//    CGSize size = [self.mlnui_layoutNode calculateLayoutWithSize:CGSizeMake(width, maxHeight)];
//    return size.height;
    return [self calculHeightWithWidth:width maxHeight:maxHeight applySize:NO];
}

- (CGSize)calculSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    MLNUILayoutNodeClearWidth(self);
    MLNUILayoutNodeClearHeight(self);
    return [self.mlnui_layoutNode calculateLayoutWithSize:CGSizeMake(maxWidth, maxHeight)];
}

- (CGFloat)calculHeightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight applySize:(BOOL)applySize {    MLNUILayoutNodeClearHeight(self);
    CGSize size = applySize
    ? [self.mlnui_layoutNode applyLayoutWithSize:CGSizeMake(width, maxHeight)]
    : [self.mlnui_layoutNode calculateLayoutWithSize:CGSizeMake(width, maxHeight)];
    return size.height;
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

- (void)setupLayoutNodeIfNeed {
    if (!self.inited) {
        [self mlnui_markNeedsLayout];
        [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) addRootnode:self.mlnui_layoutNode];
    }
}

- (void)createLuaTableWithLuaCore:(MLNUILuaCore *)luaCore
{
    _luaTable = [[MLNUILuaTable alloc] initWithMLNUILuaCore:luaCore env:MLNUILuaTableEnvRegister];
    [_luaTable setObject:self key:@"contentView"];
}

- (void)updateFrameIfNeed
{
    if (!CGSizeEqualToSize(self.frame.size, self.cell.bounds.size)) {
        CGRect frame = self.cell.bounds;
        MLNUILayoutNode *node = self.mlnui_layoutNode;
        node.marginLeft = MLNUIPointValue(frame.origin.x);
        node.marginTop = MLNUIPointValue(frame.origin.y);
        node.width = MLNUIPointValue(frame.size.width);
        node.height = MLNUIPointValue(frame.size.height);
    }
}

#pragma mark - Override

- (BOOL)mlnui_isRootView {
    return YES;
}

- (BOOL)mlnui_allowVirtualLayout {
    return NO;
}

- (void)mlnui_layoutCompleted {
    [super mlnui_layoutCompleted];
    if (CGRectEqualToRect(self.oldFrame, self.mlnuiLayoutFrame) && !CGRectEqualToRect(self.oldFrame, CGRectZero)) {
        return;
    }
    self.oldFrame = self.mlnuiLayoutFrame;
    if (self.didChangeLayout) {
        self.didChangeLayout();
    }
}

#pragma mark - Override Method For Lua
- (void)luaui_setCornerRadius:(CGFloat)cornerRadius
{
    if (self.cell) {
        [self.cell luaui_setCornerRadius:cornerRadius];
        [self.cell.contentView luaui_setCornerRadius:cornerRadius];
    }
    [super luaui_setCornerRadius:cornerRadius];
}

- (void)setLuaui_marginTop:(CGFloat)luaui_marginTop
{
    MLNUIKitLuaAssert(luaui_marginTop == 0, @"The contentView should not called marginTop");
}

- (void)setLuaui_marginLeft:(CGFloat)luaui_marginLeft
{
    MLNUIKitLuaAssert(luaui_marginLeft == 0, @"The contentView should not called marginLeft");
}

- (void)setLuaui_marginRight:(CGFloat)luaui_marginRight
{
    MLNUIKitLuaAssert(luaui_marginRight == 0, @"The contentView should not called marginRight");
}

- (void)setLuaui_marginBottom:(CGFloat)luaui_marginBottom
{
    MLNUIKitLuaAssert(luaui_marginBottom == 0, @"The contentView should not called marginBottom");
}



@end
