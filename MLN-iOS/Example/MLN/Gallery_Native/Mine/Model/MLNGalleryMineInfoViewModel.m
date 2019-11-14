//
//  MLNGalleryMineInfoViewModel.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import "MLNGalleryMineInfoViewModel.h"

@implementation MLNGalleryMineInfoNumberViewModel

- (instancetype)initWithDesc:(NSString *)desc number:(NSInteger)number
{
    if (self = [super init]) {
        self.desc = desc;
        self.number = number;
    }
    return self;
}

@end

@implementation MLNGalleryMineInfoViewModel

@end
