//
//  MLNSimpleViewPagerCell.m
//  MLN_Example
//
//  Created by Feng on 2019/11/6.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNSimpleViewPagerCell.h"
#import "MLNHomeTableView.h"

@interface MLNSimpleViewPagerCell()
@property (nonatomic, strong) MLNHomeTableView *mainTableView;
@end

@implementation MLNSimpleViewPagerCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.mainTableView.frame = self.contentView.bounds;
}

- (MLNHomeTableView *)mainTableView
{
    if (!_mainTableView) {
        _mainTableView = [[MLNHomeTableView alloc] init];
        [self.contentView addSubview:_mainTableView];
    }
    
    return _mainTableView;
}

@end
