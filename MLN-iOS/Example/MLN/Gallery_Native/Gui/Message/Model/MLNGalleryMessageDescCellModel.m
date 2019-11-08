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

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (NSString *)identifier
{
    return NSStringFromClass([self cellClass]);
}

- (Class)cellClass
{
    return [MLNGalleryMessageDescCell class];
}

- (CGFloat)cellHeight
{
    return 55.0f;
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"title"]) {
        self.name = value;
    } else if ([key isEqualToString:@"icon"]) {
        self.avatar = value;
    }
}

@end
