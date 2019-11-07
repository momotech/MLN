//
//  MLNGalleryMessageToolCell.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMessageToolCell.h"
#import "MLNGalleryMessageToolCellModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MLNGalleryMessageToolCell()

@property (nonatomic, strong) UIImageView *leftView;
@property (nonatomic, strong) UIImageView *rightView;
@property (nonatomic, strong) UILabel *titleLabel;


@end

@implementation MLNGalleryMessageToolCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.leftView.center = CGPointMake(30 + 25/2.0, self.contentView.frame.size.height / 2.0);
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.leftView.frame) + 10, 0, 100, self.contentView.frame.size.height);
    self.rightView.center = CGPointMake(self.contentView.frame.size.width - 20 - 25/2.0, self.contentView.frame.size.height / 2.0);
}


- (void)setModel:(MLNGalleryMessageToolCellModel *)model
{
    [super setModel:model];
    
    self.titleLabel.text = model.title;
    [self.leftView setImageWithURL:[NSURL URLWithString:model.leftIcon]];
    [self.rightView setImageWithURL:[NSURL URLWithString:model.rightIcon]];
}

#pragma mark - getter
- (UIImageView *)leftView
{
    if (!_leftView) {
        _leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [self.contentView addSubview:_leftView];
    }
    return _leftView;
}

- (UIImageView *)rightView
{
    if (!_rightView) {
        _rightView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [self.contentView addSubview:_rightView];
    }
    return _rightView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        _titleLabel = label;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}


@end
