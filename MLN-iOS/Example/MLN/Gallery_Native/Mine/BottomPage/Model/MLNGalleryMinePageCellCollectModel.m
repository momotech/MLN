//
//  MLNGalleryMinePageCellCollectModel.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/11.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import "MLNGalleryMinePageCellCollectModel.h"
#import "MLNGalleryMineBottomPageCollectCell.h"

@implementation MLNGalleryMinePageCellCollectCellModel

@end

@implementation MLNGalleryMinePageCellCollectModel

- (NSString *)identifier
{
    return NSStringFromClass([self cellClass]);
}

- (Class)cellClass
{
    return [MLNGalleryMineBottomPageCollectCell class];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}


@end
