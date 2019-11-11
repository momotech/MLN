//
//  MLNGalleryMineBottomPageHomeCell.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/11.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMineBottomPageHomeCell.h"
#import "MLNGalleryMinePageCellHomeModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

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
    
    UIImage *placeholder = nil;
    if (cellModel.placeholder) {
        placeholder = [UIImage imageNamed:cellModel.placeholder];
    }
    [self.infoImageView setImageWithURL:[NSURL URLWithString:cellModel.picture] placeholderImage:placeholder];
    
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
