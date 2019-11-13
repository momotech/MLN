//
//  MLNSimpleViewPagerCell.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/6.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNSimpleViewPagerCell.h"
#import <MJRefresh.h>
#import "MLNMyHttpHandler.h"
#import "MLNHomeDataHandler.h"
#import <UIView+Toast.h>
#import "MLNHomeTableViewCell.h"
#import "MLNGalleryNative.h"

@interface MLNSimpleViewPagerCell()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong, readwrite) UITableView *mainTableView;
@property (nonatomic, strong) MLNMyHttpHandler *myHttpHandler;
@property (nonatomic, assign) NSInteger mid;
@property (nonatomic, assign) NSInteger cid;
@end

static NSString *kHomeTableViewCell = @"kHomeTableViewCell";

@implementation MLNSimpleViewPagerCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.mainTableView.frame = self.contentView.bounds;
}


#pragma mark - Action
- (void)search:(UIGestureRecognizer *)gesture
{
    [self.contentView makeToast:@"网红咖啡馆"
                             duration:2.0
                             position:CSToastPositionCenter];
}

- (void)loadMoreData
{
    [self requestData:NO];
}

#pragma mark - UITableViewDataSource

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
    if ([self.tableType isEqualToString:@"follow"]) {
        return [MLNHomeDataHandler handler].dataList1.count;
    } else {
        return [MLNHomeDataHandler handler].dataList2.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLNHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHomeTableViewCell];
    if (!cell) {
        cell = [[MLNHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHomeTableViewCell];
    }
    if ([self.tableType isEqualToString:@"follow"]) {
        [cell reloadCellWithData:[MLNHomeDataHandler handler].dataList1[indexPath.row] tableType:self.tableType];
        [cell updateFollowButtonState:YES];
    } else {
        [cell reloadCellWithData:[MLNHomeDataHandler handler].dataList2[indexPath.row] tableType:self.tableType];
        [cell updateFollowButtonState:NO];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLNHomeTableViewCell *cell = [[MLNHomeTableViewCell alloc] init];
    if ([self.tableType isEqualToString:@"follow"]) {
        [cell reloadCellWithData:[MLNHomeDataHandler handler].dataList1[indexPath.row] tableType:self.tableType];
    } else {
        [cell reloadCellWithData:[MLNHomeDataHandler handler].dataList2[indexPath.row] tableType:self.tableType];
    }
    return cell.cellHeight;
}

#pragma mark - request
- (void)requestData:(BOOL)firstRequest
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    NSString *requestUrlString = @"http://v2.api.haodanku.com/itemlist/apikey/fashion/cid/1/back/20";
    [self.myHttpHandler http:nil get:requestUrlString params:@{@"mid":@(self.mid), @"cid":@(self.cid)} completionHandler:^(BOOL success, NSDictionary * _Nonnull respose, NSDictionary * _Nonnull error) {
        if (!success) {
            [self.contentView makeToast:error.description
                        duration:3.0
                        position:CSToastPositionCenter];
            return;
        }
        if ([self.tableType isEqualToString:@"follow"]) {
            if (firstRequest) {
                NSArray *dataList = [respose valueForKey:@"data"];
                [[MLNHomeDataHandler handler] updateDataList1:dataList];
                [self.mainTableView.mj_footer endRefreshing];
            } else if ([MLNHomeDataHandler handler].dataList1.count >= 200) {
                [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                NSArray *dataList = [respose valueForKey:@"data"];
                [[MLNHomeDataHandler handler] insertDataList1:dataList];
                [self.mainTableView.mj_footer endRefreshing];
            }
        } else {
            if (firstRequest) {
                NSArray *dataList = [respose valueForKey:@"data"];
                [[MLNHomeDataHandler handler] updateDataList2:dataList];
                [self.mainTableView.mj_footer endRefreshing];
            } else if ([MLNHomeDataHandler handler].dataList2.count >= 200) {
                [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                NSArray *dataList = [respose valueForKey:@"data"];
                [[MLNHomeDataHandler handler] insertDataList2:dataList];
                [self.mainTableView.mj_footer endRefreshing];
            }
        }
        
        [self.mainTableView reloadData];
    }];
#pragma clang diagnostic pop
}


- (UITableView *)mainTableView
{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] init];
        _mainTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _mainTableView.backgroundColor = [UIColor whiteColor];
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        if (@available(iOS 11.0, *)) {
            _mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.contentView addSubview:_mainTableView];
    }
    
    return _mainTableView;
}

- (MLNMyHttpHandler *)myHttpHandler
{
    if (!_myHttpHandler) {
        _myHttpHandler = [[MLNMyHttpHandler alloc] init];
    }
    return _myHttpHandler;
}

@end
