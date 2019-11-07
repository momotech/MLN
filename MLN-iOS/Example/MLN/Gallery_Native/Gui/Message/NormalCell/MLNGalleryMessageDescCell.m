//
//  MLNGalleryMessageDescCell.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMessageDescCell.h"
#import "MLNGalleryMessageDescCellModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MLNGalleryMessageDescCell()

@property (nonatomic, strong) UIImageView *avatarIcon;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *pictureImageView;
@property (nonatomic, strong) UIButton *attentionButton;

@end

@implementation MLNGalleryMessageDescCell

- (void)setModel:(MLNGalleryMessageDescCellModel *)model
{
    [super setModel:model];
    [self.avatarIcon setImageWithURL:[NSURL URLWithString:model.avatar]];
    self.nameLabel.text = model.name;
    self.descLabel.text = model.desc;
    self.timeLabel.text = model.time;
    
    switch (model.type) {
        case MLNGalleryMessageDescCellModelTypeLoveYou:{
            self.pictureImageView.hidden = NO;
            break;
        }
        case MLNGalleryMessageDescCellModelTypeAttentionYou:
            
            break;
        default:
            break;
    }
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
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)descLabel
{
    if (!_descLabel) {
        _descLabel  = [[UILabel alloc] init];
        [self.contentView addSubview:_descLabel];
    }
    return _descLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UIImageView *)pictureImageView
{
    if (!_pictureImageView) {
        _pictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [self.contentView addSubview:_pictureImageView];
    }
    return _pictureImageView;
}

- (UIButton *)attentionButton
{
    if (!_attentionButton) {
        _attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 30)];
        [self.contentView addSubview:_attentionButton];
    }
    return _attentionButton;
}

@end
