//
//  MMTableViewCell.m
//  MLN
//
//  Created by MoMo on 28/02/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "MLNTableViewCell.h"
#import "UIView+MLNLayout.h"
#import "MLNKitHeader.h"
#import "MLNLuaTable.h"

@interface MLNTableViewCell ()
@property (nonatomic, strong) UIColor *lastBackgroundColor;
@end

@implementation MLNTableViewCell

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

- (void)lua_addSubview:(UIView *)view
{
    MLNCheckTypeAndNilValue(view, @"View", UIView);
    [self.luaContentView lua_addSubview:view];
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

#pragma mark - MLNReuseCellProtocol
- (void)pushContentViewWithLuaCore:(MLNLuaCore *)luaCore
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

- (MLNLuaTable *)getLuaTable
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

- (void)requestLayoutIfNeed
{
    [self.luaContentView lua_requestLayoutIfNeed];
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
- (MLNReuseContentView *)luaContentView
{
    if (!_luaContentView) {
        _luaContentView = [[MLNReuseContentView alloc] initWithFrame:CGRectZero cellView:self];
        [self.contentView addSubview:_luaContentView];
    }
    return _luaContentView;
}

- (MLNLuaCore *)mln_luaCore
{
    return self.luaContentView.luaTable.luaCore;
}

@end
