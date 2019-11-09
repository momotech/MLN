//
//  MLNGalleryMineBottomCell.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMineBottomCell.h"
#import "MLNGalleryMineBottomCellModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MLNGalleryMineBottomCell()

@property (nonatomic, strong) UIImageView *infoImageView;

@end

@implementation MLNGalleryMineBottomCell


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.infoImageView.frame = self.bounds;
}

- (void)setInfoModel:(MLNGalleryMineBottomCellModel *)infoModel
{
    _infoModel = infoModel;
    UIImage *placeholder = nil;
    if (infoModel.placeholder) {
        placeholder = [UIImage imageNamed:infoModel.placeholder];
    }
    [self.infoImageView setImageWithURL:[NSURL URLWithString:infoModel.picture] placeholderImage:placeholder];
}

- (UIImageView *)infoImageView
{
    if (!_infoImageView) {
        _infoImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_infoImageView];
    }
    return _infoImageView;
}


@end
