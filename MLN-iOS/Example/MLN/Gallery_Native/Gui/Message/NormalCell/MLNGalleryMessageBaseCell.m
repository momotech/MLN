//
//  MLNGalleryMessageBaseCell.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/7.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMessageBaseCell.h"

@implementation MLNGalleryMessageBaseCell

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
