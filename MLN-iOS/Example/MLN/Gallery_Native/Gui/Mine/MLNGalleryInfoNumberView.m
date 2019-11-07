//
//  MLNGalleryInfoNumberView.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryInfoNumberView.h"
#import "MLNGalleryMineInfoViewModel.h"

@interface MLNGalleryInfoNumberView()

@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation MLNGalleryInfoNumberView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.numberLabel sizeToFit];
    self.numberLabel.center = CGPointMake(self.frame.size.width / 2.0, self.numberLabel.frame.size.height / 2.0);
    
    [self.infoLabel sizeToFit];
    self.infoLabel.center = CGPointMake(self.frame.size.width / 2.0, CGRectGetMaxY(self.numberLabel.frame) + 2 + self.infoLabel.frame.size.height / 2.0);
}


- (void)setInfoNumberModel:(MLNGalleryMineInfoNumberViewModel *)infoNumberModel
{
    _infoNumberModel = infoNumberModel;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", infoNumberModel.number];
    self.infoLabel.text = infoNumberModel.desc;
}

#pragma mark - getter
- (UILabel *)infoLabel
{
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:11];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.textColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0];
        [self addSubview:_infoLabel];
    }
    return _infoLabel;
}

- (UILabel *)numberLabel
{
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.font = [UIFont boldSystemFontOfSize:15];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_numberLabel];
    }
    return _numberLabel;
}

@end
