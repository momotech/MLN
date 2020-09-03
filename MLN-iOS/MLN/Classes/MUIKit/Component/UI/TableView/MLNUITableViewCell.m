//
//  MMTableViewCell.m
//  MLNUI
//
//  Created by MoMo on 28/02/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "MLNUITableViewCell.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIKitHeader.h"
#import "MLNUILuaTable.h"

@interface MLNUITableViewCell ()
@property (nonatomic, strong) UIColor *lastBackgroundColor;
@end

@implementation MLNUITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateContentViewFrameIfNeed
{
    //  reset content view frame if need
    if (self.isInited && !CGSizeEqualToSize(self.contentView.frame.size, self.frame.size)) {
        CGRect frame = self.contentView.frame;
        frame.size = self.frame.size;
        self.contentView.frame = frame;
    }
}

- (void)luaui_addSubview:(UIView *)view
{
    MLNUICheckTypeAndNilValue(view, @"View", UIView);
    [self.luaContentView luaui_addSubview:view];
}

- (void)reloadCellIfNeeded {
    if ([self.delegate respondsToSelector:@selector(mlnuiTableViewCellShouldReload:)]) {
        [self.delegate mlnuiTableViewCellShouldReload:self];
    }
}

#pragma mark - highlightColor
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self highlightCell:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self highlightCell:NO];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self highlightCell:NO];
}

- (void)highlightCell:(BOOL)highlighted
{
    if (!self.delegate.isShowPressedColor) {
        return;
    }
    if (highlighted) {
        self.lastBackgroundColor = self.luaContentView.backgroundColor;
        self.luaContentView.backgroundColor = [self.delegate pressedColor];
    } else {
        if (self.lastBackgroundColor) {
            [UIView animateWithDuration:0.05 animations:^{
                self.luaContentView.backgroundColor = self.lastBackgroundColor;
            }];
        }
    }
}

#pragma mark - MLNUIReuseCellProtocol
- (void)pushContentViewWithLuaCore:(MLNUILuaCore *)luaCore
{
    [self updateContentViewFrameIfNeed];
    [self.luaContentView pushToLuaCore:luaCore];
}

- (void)setupLayoutNodeIfNeed
{
    [self.luaContentView setupLayoutNodeIfNeed];
}

- (void)updateLuaContentViewIfNeed
{
    [self.luaContentView updateFrameIfNeed];
}

- (MLNUILuaTable *)getLuaTable
{
    return self.luaContentView.luaTable;
}

- (BOOL)isInited
{
    return self.luaContentView.isInited;
}

- (void)initCompleted
{
    [self.luaContentView setInited:YES];
}

- (CGFloat)calculHeightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight
{
    return [self.luaContentView calculHeightWithWidth:width maxHeight:maxHeight];
}

- (CGSize)calculSizeWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    return [self.luaContentView calculSizeWithMaxWidth:maxWidth maxHeight:maxHeight];
}

- (CGFloat)calculHeightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight applySize:(BOOL)applySize {
    return [self.luaContentView calculHeightWithWidth:width maxHeight:maxHeight applySize:applySize];
}

- (void)mlnui_requestLayoutIfNeed
{
    [self.luaContentView mlnui_requestLayoutIfNeed];
}

- (void)updateSubviewsFrameIfNeed
{
    [self updateContentViewFrameIfNeed];
    [self.luaContentView updateFrameIfNeed];
}

- (void)updateLastReueseId:(NSString *)lastReuaseId
{
    self.luaContentView.lastReuaseId = lastReuaseId;
}

- (NSString *)lastReueseId
{
    return self.luaContentView.lastReuaseId;
}

#pragma mark - Getter
- (MLNUIReuseContentView *)luaContentView
{
    if (!_luaContentView) {
        _luaContentView = [[MLNUIReuseContentView alloc] initWithFrame:CGRectZero cellView:self];
//        __weak typeof(self) weakSelf = self;
//        _luaContentView.didChangeLayout = ^{
//            [weakSelf reloadCellIfNeeded]; // 会导致无限reload
//        };
        [self.contentView addSubview:_luaContentView];
    }
    return _luaContentView;
}

- (MLNUILuaCore *)mlnui_luaCore
{
    return self.luaContentView.luaTable.luaCore;
}

@end
