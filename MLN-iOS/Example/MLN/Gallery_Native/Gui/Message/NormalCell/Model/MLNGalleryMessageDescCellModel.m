//
//  MLNGalleryMessageDescCellModel.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMessageDescCellModel.h"
#import "MLNGalleryMessageDescCell.h"

@implementation MLNGalleryMessageDescCellModel

- (NSString *)identifier
{
    return NSStringFromClass([self cellClass]);
}

- (Class)cellClass
{
    return [MLNGalleryMessageDescCell class];
}


@end
