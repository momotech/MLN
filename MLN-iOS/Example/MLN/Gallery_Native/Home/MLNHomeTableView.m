//
//  MLNHomeTableView.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/6.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNHomeTableView.h"
#import "MLNHomeTableViewCell.h"
#import "MLNGalleryNative.h"
#import <MJRefresh.h>

@interface MLNHomeTableView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, copy) RefreshBlock refreshBlock;
@property (nonatomic, copy) LoadingBlock loadingBlock;
@property (nonatomic, copy) SearchBlock searchBlock;

@end

static NSString *kHomeTableViewCell = @"kHomeTableViewCell";

@implementation MLNHomeTableView

- (void)reloadTableWithDataList:(NSArray *)dataList
{
    _dataList = dataList;
    
    [self.tableView reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
}

- (void)setRefreshBlock:(RefreshBlock)refreshBlock
{
    _refreshBlock = refreshBlock;
}

- (void)setLoadingBlock:(LoadingBlock)loadingBlock
{
    _loadingBlock = loadingBlock;
}

- (void)setSearchBlock:(SearchBlock)searchBlock
{
    _searchBlock = searchBlock;
}

#pragma mark - Action
- (void)search:(UIGestureRecognizer *)gesture
{
    if (self.searchBlock) {
        self.searchBlock();
    }
}

- (void)refresh
{
    if (self.refreshBlock) {
        self.refreshBlock(self.tableView);
    }
}

- (void)loading
{
    if (self.loadingBlock) {
        self.loadingBlock(self.tableView);
    }
}






#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, kScreenWidth - 40, 36)];
    label.font = [UIFont systemFontOfSize:13];
    label.backgroundColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:0.1];
    label.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:0.4];
    label.text = @"大家都在搜\"网红咖啡馆\"";
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 18;
    label.layer.masksToBounds = YES;
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(search:)];
    [label addGestureRecognizer:tapGesture];
    [headerView addSubview:label];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLNHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHomeTableViewCell];
    if (!cell) {
        cell = [[MLNHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHomeTableViewCell];
    }
    [cell reloadCellWithData:self.dataList[indexPath.row]];
    if ([self.tableType isEqualToString:@"follow"]) {
        [cell updateFollowButtonState:NO];
    } else {
        [cell updateFollowButtonState:YES];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLNHomeTableViewCell *cell = [[MLNHomeTableViewCell alloc] init];
    [cell reloadCellWithData:self.dataList[indexPath.row]];
    return cell.cellHeight;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
//        _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loading)];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:_tableView];
    }
    return _tableView;
}

@end
