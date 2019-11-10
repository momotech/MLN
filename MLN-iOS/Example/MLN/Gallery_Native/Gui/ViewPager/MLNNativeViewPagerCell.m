//
//  MLNNativeViewPagerCell.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/6.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNNativeViewPagerCell.h"

@interface MLNNativeViewPagerCell()
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation MLNNativeViewPagerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    self.tableView.backgroundColor = [UIColor blueColor];
    
}

- (void)setupSubviews
{
    [self addSubview:self.tableView];
}


#pragma mark - TableView

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
    }
    
    return _tableView;
}

@end
