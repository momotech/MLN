//
//  MLNGalleryMinePageCellDynamicModel.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/11.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import "MLNGalleryMinePageCellDynamicModel.h"
#import "MLNGalleryMineBottomPageDynamicCell.h"

@implementation MLNGalleryMinePageCellDynamicModel

- (NSString *)identifier
{
    return NSStringFromClass([self cellClass]);
}

- (Class)cellClass
{
    return [MLNGalleryMineBottomPageDynamicCell class];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
