//
//  MLNGalleryMessageDescCell.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import "MLNGalleryMessageDescCell.h"
#import "MLNGalleryMessageDescCellModel.h"
#import <UIImageView+WebCache.h>

@interface MLNGalleryMessageDescCell()

@property (nonatomic, strong) UIImageView *avatarIcon;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *pictureImageView;
@property (nonatomic, strong) UIButton *attentionButton;

@end

@implementation MLNGalleryMessageDescCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect contentFrame = self.contentView.frame;
    
    self.avatarIcon.center = CGPointMake(20 + 20, contentFrame.size.height * 0.5);
    
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = (CGRect){CGPointMake(CGRectGetMaxX(self.avatarIcon.frame) + 10, self.avatarIcon.frame.origin.y), self.nameLabel.frame.size};
    [self.descLabel sizeToFit];
    self.descLabel.frame = (CGRect){CGPointMake(CGRectGetMaxX(self.nameLabel.frame) + 5, self.nameLabel.frame.origin.y) , self.descLabel.frame.size};
    
    [self.timeLabel sizeToFit];
    self.timeLabel.frame = (CGRect){CGPointMake(self.nameLabel.frame.origin.x, CGRectGetMaxY(self.nameLabel.frame) + 5), self.timeLabel.frame.size};
    
    _attentionButton.frame = CGRectMake(contentFrame.size.width - 60 - 20, (contentFrame.size.height - 30)/2.0 , 60, 30);
    _pictureImageView.frame = CGRectMake(contentFrame.size.width - 40 - 20 , (contentFrame.size.height - 40)/2.0, 40, 40);
}

- (void)setModel:(MLNGalleryMessageDescCellModel *)model
{
    [super setModel:model];
    [self.avatarIcon sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
    
    self.nameLabel.text = model.name;
    self.descLabel.text = model.desc;
    self.timeLabel.text = model.time;
    
    self.attentionButton.hidden = NO;
    self.pictureImageView.hidden = YES;
}


#pragma mark - getter
- (UIImageView *)avatarIcon
{
    if (!_avatarIcon) {
        _avatarIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _avatarIcon.clipsToBounds = YES;
        _avatarIcon.layer.cornerRadius = 20;
        [self.contentView addSubview:_avatarIcon];
    }
    return _avatarIcon;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)descLabel
{
    if (!_descLabel) {
        _descLabel  = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:13];
        _descLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_descLabel];
    }
    return _descLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UIImageView *)pictureImageView
{
    if (!_pictureImageView) {
        _pictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        _pictureImageView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:242 / 255.0 blue:221 / 255.0 alpha:1.0];
        [self.contentView addSubview:_pictureImageView];
    }
    return _pictureImageView;
}

- (UIButton *)attentionButton
{
    if (!_attentionButton) {
        _attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 30)];
        _attentionButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_attentionButton addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        [_attentionButton setTitle:@"+关注" forState:UIControlStateNormal];
        [_attentionButton setTitle:@"已关注" forState:UIControlStateSelected];
        [_attentionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _attentionButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _attentionButton.layer.borderWidth = 0.5;
        [self.contentView addSubview:_attentionButton];
    }
    return _attentionButton;
}

- (void)clickAction:(UIButton *)button
{
    button.selected = !button.selected;
}

@end
