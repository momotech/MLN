//
//  MLNUICollectionViewCell.m
//
//
//  Created by MoMo on 2018/7/17.
//

#import "MLNUICollectionViewCell.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIKitHeader.h"
#import "MLNUILuaTable.h"

@interface MLNUICollectionViewCell ()

@property (nonatomic, strong) MLNUIReuseContentView *luaContentView;

@end

@implementation MLNUICollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
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
    MLNUICheckTypeAndNilValue(view, @"View", [UIView class]);
    [self.luaContentView luaui_addSubview:view];
}

- (void)reloadCellIfNeeded {
    if ([self.delegate respondsToSelector:@selector(mlnuiCollectionViewCellShouldReload:)]) {
        [self.delegate mlnuiCollectionViewCellShouldReload:self];
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
        __weak typeof(self) weakSelf = self;
        _luaContentView.didChangeLayout = ^{ [weakSelf reloadCellIfNeeded]; };
        [self.contentView addSubview:_luaContentView];
    }
    return _luaContentView;
}

- (MLNUILuaCore *)mlnui_luaCore
{
    return self.luaContentView.luaTable.luaCore;
}

@end
