//
//  MLNGalleryMineBottomPageCollectCell.m
//  MLN_Example
//
//  Created by MOMO on 2019/11/11.
//  Copyright © 2019年 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMineBottomPageCollectCell.h"
#import "MLNGalleryMinePageCellCollectModel.h"
#import "MLNGalleryMinePageCellCollectCell.h"

@interface MLNGalleryMineBottomPageCollectCell()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *lightGrayView;

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *actionButton;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MLNGalleryMineBottomPageCollectCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.lightGrayView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, 10);
    
    [self.textLabel sizeToFit];
    self.textLabel.frame = CGRectMake(20, 10, 200, 70);
    
    self.actionButton.frame = CGRectMake(self.contentView.frame.size.width - 80, 10, 80, 70);
    
    self.tableView.frame = CGRectMake(0, 80, self.contentView.frame.size.width, self.contentView.frame.size.height - 80);
    
}

- (void)setCellModel:(MLNGalleryMinePageCellBaseModel *)cellModel
{
    [super setCellModel:cellModel];
    MLNGalleryMinePageCellCollectModel *model = (MLNGalleryMinePageCellCollectModel *)self.cellModel;
    self.textLabel.text = model.title;
    [self.actionButton setTitle:model.buttonTitle forState:UIControlStateNormal];
    
    [self.tableView reloadData];
}

- (UIView *)lightGrayView
{
    if (!_lightGrayView) {
        _lightGrayView = [[UIView alloc] init];
        _lightGrayView.backgroundColor = [UIColor colorWithRed:121/255.0 green:121/255.0 blue:121/255.0 alpha:0.4];
        [self.contentView addSubview:_lightGrayView];
    }
    return _lightGrayView;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor whiteColor];
        _textLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:_textLabel];
    }
    return _textLabel;
}

- (UIButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
        [_actionButton addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        [_actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:_actionButton];
    }
    return _actionButton;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[MLNGalleryMinePageCellCollectCell class] forCellReuseIdentifier:@"MLNGalleryMinePageCellCollectCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.contentView addSubview:_tableView];
    }
    return _tableView;
}

- (void)clickAction:(UIButton *)button
{
    MLNGalleryMinePageCellCollectModel *model = (MLNGalleryMinePageCellCollectModel *)self.cellModel;
    if (model.clickActionBlock) {
        model.clickActionBlock();
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MLNGalleryMinePageCellCollectModel *model = (MLNGalleryMinePageCellCollectModel *)self.cellModel;
    return model.dataCellModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLNGalleryMinePageCellCollectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MLNGalleryMinePageCellCollectCell"];
    MLNGalleryMinePageCellCollectModel *model = (MLNGalleryMinePageCellCollectModel *)self.cellModel;
    cell.cellModel = [model.dataCellModels objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
