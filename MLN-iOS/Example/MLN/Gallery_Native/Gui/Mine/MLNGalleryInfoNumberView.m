//
//  MLNGalleryInfoNumberView.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryInfoNumberView.h"

@interface MLNGalleryInfoNumberView()

@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation MLNGalleryInfoNumberView



#pragma mark - getter
- (UILabel *)infoLabel
{
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
    }
}


@end
