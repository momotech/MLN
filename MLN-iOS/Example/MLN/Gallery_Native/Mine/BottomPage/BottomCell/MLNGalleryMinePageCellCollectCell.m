//
//  MLNGalleryMinePageCellCollectCell.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/11.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import "MLNGalleryMinePageCellCollectCell.h"
#import "MLNGalleryMinePageCellCollectModel.h"
#import <UIImageView+WebCache.h>

@interface MLNGalleryMinePageCellCollectCell()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *rightIcon;

@end

@implementation MLNGalleryMinePageCellCollectCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarView.frame) + 10, 5, 100, 18);
    [self.descLabel sizeToFit];
    self.descLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarView.frame) + 10 , CGRectGetMaxY(self.titleLabel.frame) + 5 , self.descLabel.frame.size.width, self.descLabel.frame.size.height);
    self.rightIcon.center = CGPointMake(self.contentView.frame.size.width - 40, self.contentView.frame.size.height /2.0);
}


- (void)setCellModel:(MLNGalleryMinePageCellCollectCellModel *)cellModel
{
    _cellModel = cellModel;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:cellModel.avatar]];
    self.titleLabel.text = cellModel.title;
    self.descLabel.text = cellModel.desc;
    [self.rightIcon sd_setImageWithURL:[NSURL URLWithString:cellModel.righticon]];
}

- (UIImageView *)avatarView
{
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 50, 50)];
        [self.contentView addSubview:_avatarView];
    }
    return _avatarView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)descLabel
{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:13];
        _descLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_descLabel];
    }
    return _descLabel;
}

- (UIImageView *)rightIcon
{
    if (!_rightIcon) {
        _rightIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self.contentView addSubview:_rightIcon];
    }
    return _rightIcon;
}

@end
