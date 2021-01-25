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

- (void)luaui_addSubview:(UIView *)view
{
    MLNUICheckTypeAndNilValue(view, @"View", UIView);
    [self.luaContentView luaui_addSubview:view];
}

- (void)reloadCellIfNeededWithSize:(CGSize)size {
    if ([self.delegate respondsToSelector:@selector(mlnuiTableViewCellShouldReload:size:)]) {
        [self.delegate mlnuiTableViewCellShouldReload:self size:size];
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

- (MLNUILuaTable *)createLuaTableAsCellNameForLuaIfNeed:(MLNUILuaCore *)luaCore {
    return [self.luaContentView createLuaTableAsCellNameForLuaIfNeed:luaCore];
}

- (void)createLayoutNodeIfNeedWithFitSize:(CGSize)fitSize maxSize:(CGSize)maxSize {
    [self.luaContentView createLayoutNodeIfNeedWithFitSize:fitSize maxSize:maxSize];
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

- (CGSize)caculateCellSizeWithMaxSize:(CGSize)maxSize apply:(BOOL)apply {
    return [self.luaContentView caculateContentViewSizeWithFitSize:CGSizeMake(maxSize.width, 0) maxSize:maxSize apply:apply];
}

- (CGSize)caculateCellSizeWithFitSize:(CGSize)fitSize maxSize:(CGSize)maxSize apply:(BOOL)apply {
    return [self.luaContentView caculateContentViewSizeWithFitSize:fitSize maxSize:maxSize apply:apply];
}

- (void)mlnui_requestLayoutIfNeed
{
    [self.luaContentView mlnui_requestLayoutIfNeed];
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
        _luaContentView = [[self.reuseContentViewClass alloc] initWithFrame:CGRectZero cellView:self];
        __weak typeof(self) weakSelf = self;
        _luaContentView.didChangeLayout = ^(CGSize size) {
            [weakSelf reloadCellIfNeededWithSize:size];
        };
        [self.contentView addSubview:_luaContentView];
    }
    return _luaContentView;
}

- (MLNUILuaCore *)mlnui_luaCore
{
    return self.luaContentView.luaTable.luaCore;
}

- (Class)reuseContentViewClass {
    return [MLNUIReuseContentView class];
}

@end

@implementation MLNUITableViewAutoHeightCell

#pragma mark - Override

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = YES;
    }
    return self;
}

- (Class)reuseContentViewClass {
    return [MLNUIReuseAutoSizeContentView class];
}

@end
