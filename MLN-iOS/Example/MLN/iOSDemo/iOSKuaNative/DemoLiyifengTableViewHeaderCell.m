//
//  DemoTableViewHeaderCell.m
//  MyFirstDemo
//
//  Created by MOMO on 2020/9/2.
//  Copyright © 2020 MOMO. All rights reserved.
//

#import "DemoLiyifengTableViewHeaderCell.h"
//#import "DemoFirstViewController.h"
#import "DemoTableViewHeaderView.h"
#import <Masonry/Masonry.h>

@implementation DemoLiyifengTableViewHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        DemoTableViewHeaderView *TableViewHeaderView = [DemoTableViewHeaderView new];
        [self.contentView addSubview:TableViewHeaderView];
        [TableViewHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
    }
    return self;
}

@end
