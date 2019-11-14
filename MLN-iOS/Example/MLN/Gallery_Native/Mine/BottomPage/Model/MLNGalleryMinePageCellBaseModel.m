//
//  MLNGalleryMinePageCellBaseModel.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/11.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMinePageCellBaseModel.h"
#import "MLNGalleryMineBottomPageBaseCell.h"

@implementation MLNGalleryMinePageCellBaseModel

- (NSString *)identifier
{
    return NSStringFromClass([self cellClass]);
}

- (Class)cellClass
{
    return [MLNGalleryMineBottomPageBaseCell class];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
