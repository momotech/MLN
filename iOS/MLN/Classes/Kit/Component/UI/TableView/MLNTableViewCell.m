//
//  MMTableViewCell.m
//  MomoChat
//
//  Created by MoMo on 28/02/2018.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "MLNTableViewCell.h"
#import "UIView+MLNLayout.h"

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
    [self.luaContentView lua_addSubview:view];
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

@end
