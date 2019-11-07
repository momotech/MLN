//
//  MLNGalleryMineHeaderView.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMineHeaderView.h"
#import "MLNGalleryInfoNumberView.h"
#import "MLNGalleryMineInfoViewModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MLNGalleryMineHeaderView()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *locationLabel;

@property (nonatomic, strong) NSMutableArray *infoNumberViews;

@property (nonatomic, strong) UIButton *clickButton;

@property (nonatomic, strong) UIView *lineView;

@end

@implementation MLNGalleryMineHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupSelfView];
    }
    return self;
}

- (void)setupSelfView
{
    [self avatarImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self avatarImageView];
    
    [self.nameLabel sizeToFit];
    self.nameLabel.center = CGPointMake(self.avatarImageView.center.x, CGRectGetMaxY(self.avatarImageView.frame) + 15 + self.nameLabel.frame.size.height * 0.5);
    
    [self.locationLabel sizeToFit];
    self.locationLabel.center = CGPointMake(self.avatarImageView.center.x, CGRectGetMaxY(self.nameLabel.frame) + 5 + self.locationLabel.frame.size.height * 0.5);

    CGFloat inWidth = 80;
    CGFloat inX = CGRectGetMaxX(self.avatarImageView.frame) + 20;
    CGFloat inY = 20;
    for (MLNGalleryInfoNumberView *view in self.infoNumberViews) {
        if (view.isHidden == NO) {
            view.frame = CGRectMake(inX, inY, inWidth, inWidth);
            inX = CGRectGetMaxX(view.frame);
        }
    }
    
    self.clickButton.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + 20, 90, 240, 30);
    
    self.lineView.frame = CGRectMake(20, CGRectGetMaxY(self.locationLabel.frame) + 20, self.frame.size.width - 40, 0.5);
}

- (void)setMineInfoModel:(MLNGalleryMineInfoViewModel *)mineInfoModel
{
    _mineInfoModel = mineInfoModel;
    UIImage *placeholder = nil;
    if (mineInfoModel.placeholder != nil) {
        placeholder  = [UIImage imageNamed:mineInfoModel.placeholder];
    }
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:mineInfoModel.avatar] placeholderImage:placeholder];
    
    self.nameLabel.text = mineInfoModel.name;
    self.locationLabel.text = mineInfoModel.location;
    
    for (MLNGalleryInfoNumberView *view in self.infoNumberViews) {
        view.hidden = YES;
    }
    
    for (NSUInteger index = 0; index < self.mineInfoModel.infoNumbers.count; index++) {
        MLNGalleryInfoNumberView *inView = nil;
        if (index < self.infoNumberViews.count) {
            inView = [self.infoNumberViews objectAtIndex:index];
        }
        if (!inView) {
            inView = [[MLNGalleryInfoNumberView alloc] init];
        }
        inView.infoNumberModel = [self.mineInfoModel.infoNumbers objectAtIndex:index];
        [self addSubview:inView];
        [self.infoNumberViews addObject:inView];
        inView.hidden = NO;
    }
    
    [self.clickButton setTitle:mineInfoModel.clickTitle forState:UIControlStateNormal];
}

#pragma mark - getter
- (UIImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 80, 80)];
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.layer.cornerRadius = 40;
        [self addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)locationLabel
{
    if (!_locationLabel) {
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.font = [UIFont systemFontOfSize:13];
        _locationLabel.textColor = [UIColor colorWithRed:60 / 255.0 green:60 / 255.0 blue:60 / 255.0 alpha:1.0];
        [self addSubview:_locationLabel];
    }
    return _locationLabel;
}

- (NSMutableArray *)infoNumberViews
{
    if (!_infoNumberViews) {
        _infoNumberViews = [NSMutableArray array];
    }
    return _infoNumberViews;
}

- (UIButton *)clickButton
{
    if (!_clickButton) {
        _clickButton = [[UIButton alloc] init];
        [_clickButton addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        [_clickButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _clickButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _clickButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _clickButton.layer.cornerRadius = 3;
        _clickButton.layer.borderWidth = 0.5;
        [self addSubview:_clickButton];
    }
    return _clickButton;
}

#pragma mark - action
- (void)clickAction:(UIButton *)btn
{
    if (_mineInfoModel.clickActionBlock) {
        _mineInfoModel.clickActionBlock();
    }
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRed:210 / 255.0 green:210 / 255.0 blue:210 / 255.0 alpha:1.0];
        [self addSubview:_lineView];
    }
    return _lineView;
}

@end
