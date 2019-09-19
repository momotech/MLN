//
//  MLNCollectionViewCell.m
//  
//
//  Created by MoMo on 2018/7/17.
//

#import "MLNCollectionViewCell.h"
#import "UIView+MLNLayout.h"

@interface MLNCollectionViewCell ()

@property (nonatomic, strong) MLNReuseContentView *luaContentView;

@end

@implementation MLNCollectionViewCell

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
