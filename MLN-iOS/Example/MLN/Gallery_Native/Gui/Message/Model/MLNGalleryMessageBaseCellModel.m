//
//  MLNGalleryMessageBaseCell.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMessageBaseCellModel.h"
#import "MLNGalleryMessageBaseCell.h"

@implementation MLNGalleryMessageBaseCellModel

- (NSString *)identifier
{
    return NSStringFromClass([self class]);
}

- (Class)cellClass
{
    return [MLNGalleryMessageBaseCell class];
}

- (CGFloat)cellHeight
{
    return 45.0f;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
