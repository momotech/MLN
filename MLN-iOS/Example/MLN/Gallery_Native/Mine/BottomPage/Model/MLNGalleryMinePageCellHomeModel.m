//
//  MLNGalleryMinePageCellHomeModel.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/11.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import "MLNGalleryMinePageCellHomeModel.h"
#import "MLNGalleryMineBottomPageHomeCell.h"

@implementation MLNGalleryMinePageCellHomeModel

- (NSString *)identifier
{
    return NSStringFromClass([self cellClass]);
}

- (Class)cellClass
{
    return [MLNGalleryMineBottomPageHomeCell class];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
