//
//  MLNGalleryMineBottomPageDynamicCell.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/11.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMineBottomPageDynamicCell.h"
#import "MLNGalleryMinePageCellDynamicModel.h"
#import <UIImageView+WebCache.h>

@interface MLNGalleryMineBottomPageDynamicCell()

@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MLNGalleryMineBottomPageDynamicCell


- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.dayLabel sizeToFit];
    self.dayLabel.center = CGPointMake(30 + self.dayLabel.frame.size.width * 0.5 , (40 - self.dayLabel.frame.size.height) / 2.0);
    
    [self.dateLabel sizeToFit];
    self.dateLabel.center = CGPointMake(CGRectGetMaxX(self.dayLabel.frame) + 10 + self.dateLabel.frame.size.width * 0.5, self.dayLabel.center.y);
    
    self.imageView.frame = CGRectMake(30, 40, self.contentView.frame.size.width - 60, self.contentView.frame.size.height - 40);
}

- (void)setCellModel:(MLNGalleryMinePageCellBaseModel *)cellModel
{
    [super setCellModel:cellModel];
    MLNGalleryMinePageCellDynamicModel *model = (MLNGalleryMinePageCellDynamicModel *)cellModel;
    
    self.dayLabel.text = model.day;
    self.dateLabel.text = model.date;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.picture]];
}

- (UILabel *)dayLabel
{
    if (!_dayLabel) {
        _dayLabel = [[UILabel alloc] init];
        _dayLabel.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:_dayLabel];
    }
    return _dayLabel;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont systemFontOfSize:15];
        _dateLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}


@end
