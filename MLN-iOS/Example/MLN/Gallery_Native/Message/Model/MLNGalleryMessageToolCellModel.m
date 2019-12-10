//
//  MLNGalleryMessageToolCellModel.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import "MLNGalleryMessageToolCellModel.h"
#import "MLNGalleryMessageToolCell.h"

@implementation MLNGalleryMessageToolCellModel

- (NSString *)identifier
{
    return NSStringFromClass([self cellClass]);
}

- (Class)cellClass
{
    return [MLNGalleryMessageToolCell class];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
