//
//  MLNGalleryMessageViewController.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/5.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNGalleryMessageViewController.h"
#import "MLNGalleryNavigationBar.h"
#import "MLNGalleryMessageBaseCellModel.h"
#import "MLNGalleryMessageBaseCell.h"
#import "MLNGalleryMessageToolCellModel.h"
#import "MLNGalleryMessageDescCellModel.h"
#import <MJRefresh.h>
#import "MLNGalleryMessageDetailViewController.h"
#import "MLNMyHttpHandler.h"
#import <UIView+Toast.h>
#import "MLNLoadTimeStatistics.h"

#define kMLNTabBarHeight 44

@interface MLNGalleryMessageViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MLNGalleryNavigationBar *navigationBar;

@property (nonatomic, strong) UITableView *mainView;

@property (nonatomic, strong) NSMutableArray <MLNGalleryMessageBaseCellModel *>* models;

@property (nonatomic, strong) MLNMyHttpHandler *myHttpHandler;

@end

@implementation MLNGalleryMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigation];
    [self requestMessageData:YES];
}

- (void)setupNavigation
{
    [self.navigationBar setTitle:@"消息"];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [[MLNLoadTimeStatistics sharedInstance] recordEndTime];
    NSLog(@">>>>>>>>>>>>>消息布局完成：%@", @([[MLNLoadTimeStatistics sharedInstance] allLoadTime] * 1000));
}

#pragma mark - Actions
- (void)loadNewData
{
    [self requestMessageData:YES];
}

- (void)loadMoreData
{
    [self requestMessageData:NO];
}

#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLNGalleryMessageBaseCellModel *model = nil;
    if (indexPath.row < self.models.count) {
        model = [self.models objectAtIndex:indexPath.row];
    } else {
        model = [MLNGalleryMessageBaseCellModel new];
    }
    MLNGalleryMessageBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:model.identifier];
    if (!cell) {
        [tableView registerClass:model.cellClass forCellReuseIdentifier:model.identifier];
        cell = [tableView dequeueReusableCellWithIdentifier:model.identifier];
    }
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLNGalleryMessageBaseCellModel *model = nil;
    if (indexPath.row < self.models.count) {
        model = [self.models objectAtIndex:indexPath.row];
    } else {
        model = [MLNGalleryMessageBaseCellModel new];
    }
    return model.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[MLNLoadTimeStatistics sharedInstance] recordStartTime];
    MLNGalleryMessageDetailViewController *messageDetailController = [[MLNGalleryMessageDetailViewController alloc] init];
    if (indexPath.row == 0) {
        messageDetailController.titleString = @"私信";
        [self.navigationController pushViewController:messageDetailController animated:YES];
    } else if(indexPath.row == 1) {
        messageDetailController.titleString = @"官方通知";
        [self.navigationController pushViewController:messageDetailController animated:YES];
    }
}


#pragma mark - Private method

- (void)requestMessageData:(BOOL)firstRequest
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    NSString *requestUrlString = @"https://www.apiopen.top/femaleNameApi";
    [self.myHttpHandler http:nil get:requestUrlString params:nil completionHandler:^(BOOL success, NSDictionary * _Nonnull respose, NSDictionary * _Nonnull error) {
        if (!success) {
            [self.view makeToast:error.description
                        duration:3.0
                        position:CSToastPositionCenter];
            return;
        }
        NSDictionary *result = [respose valueForKey:@"result"];
        if (firstRequest) {
            [self.models removeAllObjects];
            [self.mainView.mj_header endRefreshing];
            // 解析数据
            NSArray *tools = [result valueForKey:@"tools"];
            NSMutableArray *toolsArray = [NSMutableArray array];
            for (NSDictionary *itemDict in tools) {
                if ([itemDict isKindOfClass:[NSDictionary class]]) {
                    MLNGalleryMessageToolCellModel *toolModel = [[MLNGalleryMessageToolCellModel alloc] init];
                    toolModel.leftIcon = [itemDict valueForKey:@"leftIcon"];
                    toolModel.title = [itemDict valueForKey:@"title"];
                    toolModel.rightIcon = [itemDict valueForKey:@"rightIcon"];
                    [toolsArray addObject:toolModel];
                }
            }
            [self.models addObjectsFromArray:toolsArray];

            NSArray *dataArray = [result valueForKey:@"data"];
            NSMutableArray *models = [NSMutableArray array];
            for (NSDictionary *itemDict in dataArray) {
                if ([itemDict isKindOfClass:[NSDictionary class]]) {
                    MLNGalleryMessageDescCellModel *cellModel = [[MLNGalleryMessageDescCellModel alloc] initWithDict:itemDict];
                    [models addObject:cellModel];
                }
            }
            [self.models addObjectsFromArray:models];
            [self.mainView reloadData];
        } else if (self.models.count >= 20) {
            [self.mainView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.mainView.mj_footer endRefreshing];
            NSArray *dataArray = [respose valueForKey:@"data"];
            NSMutableArray *models = [NSMutableArray array];
            for (NSDictionary *itemDict in dataArray) {
                if ([itemDict isKindOfClass:[NSDictionary class]]) {
                    MLNGalleryMessageDescCellModel *cellModel = [[MLNGalleryMessageDescCellModel alloc] initWithDict:itemDict];
                    [models addObject:cellModel];
                }
            }
            [self.models addObjectsFromArray:models];
            [self.mainView reloadData];
        }
    }];
#pragma clang diagnostic pop
}


#pragma mark - getter
- (MLNGalleryNavigationBar *)navigationBar
{
    if (!_navigationBar) {
        _navigationBar = [[MLNGalleryNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kMLNNavigatorHeight)];
        [self.view addSubview:_navigationBar];
    }
    return _navigationBar;
}

- (UITableView *)mainView
{
    if (!_mainView) {
        _mainView = [[UITableView alloc] initWithFrame:CGRectMake(0, kMLNNavigatorHeight, self.view.frame.size.width, self.view.frame.size.height - kMLNNavigatorHeight - kMLNTabBarHeight) style:UITableViewStylePlain];
        _mainView.separatorStyle = UITableViewCellEditingStyleNone;
        _mainView.delegate = self;
        _mainView.dataSource = self;
        _mainView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        _mainView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        [self.view addSubview:_mainView];
    }
    return _mainView;
}

- (NSMutableArray<MLNGalleryMessageBaseCellModel *> *)models
{
    if (!_models) {
        _models = [NSMutableArray array];
    }
    return _models;
}

- (MLNMyHttpHandler *)myHttpHandler
{
    if (!_myHttpHandler) {
        _myHttpHandler = [[MLNMyHttpHandler alloc] init];
    }
    return _myHttpHandler;
}


@end
