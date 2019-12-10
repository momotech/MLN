//
//  MLNGalleryMineBottomPageHomeCell.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/11.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import "MLNGalleryMineBottomPageHomeCell.h"
#import "MLNGalleryMinePageCellHomeModel.h"
#import <UIImageView+WebCache.h>

@interface MLNGalleryMineBottomPageHomeCell()

@property (nonatomic, strong) UIImageView *infoImageView;

@end

@implementation MLNGalleryMineBottomPageHomeCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.infoImageView.frame = CGRectMake(0, 0, 140, 160);
}

- (void)setCellModel:(MLNGalleryMinePageCellHomeModel *)cellModel
{
    [super setCellModel:(MLNGalleryMinePageCellBaseModel *)cellModel];
    [self.infoImageView sd_setImageWithURL:[NSURL URLWithString:cellModel.picture]];
    
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
