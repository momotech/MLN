//
//  MLNGalleryMessageViewController.m
//  MLN_Example
//
//  Created by Feng on 2019/11/5.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMessageViewController.h"
#import "MLNGalleryNavigationBar.h"
#import "MLNGalleryMessageBaseCellModel.h"
#import "MLNGalleryMessageBaseCell.h"
#import "MLNGalleryMessageToolCellModel.h"
#import "MLNGalleryMessageDescCellModel.h"
#import <MJRefresh.h>

#define kMLNTabBarHeight 44

@interface MLNGalleryMessageViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MLNGalleryNavigationBar *navigationBar;

@property (nonatomic, strong) UITableView *mainView;

@property (nonatomic, strong) NSMutableArray <MLNGalleryMessageBaseCellModel *>* models;

@end

@implementation MLNGalleryMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigation];
    
    [self setupMainView];
}

- (void)setupNavigation
{
    [self.navigationBar setTitle:@"消息"];
}

- (void)setupMainView
{
    [self reloadData];
    [self loadMoreData];
    
    __weak typeof(self) weakSelf = self;
    self.mainView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf reloadData];
        [strongSelf loadMoreData];
        [strongSelf.mainView.mj_header endRefreshing];
        [strongSelf.mainView reloadData];
    }];
    
    self.mainView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.mainView.mj_footer endRefreshing];
        [strongSelf loadMoreData];
        [strongSelf.mainView reloadData];
    }];
    
    [self.mainView reloadData];
}

- (void)reloadData
{
    [self.models removeAllObjects];
    
    MLNGalleryMessageToolCellModel *tool1 = [[MLNGalleryMessageToolCellModel alloc] init];
    tool1.leftIcon = @"https://s.momocdn.com/w/u/others/2019/08/31/1567263950353-service.png";
    tool1.title = @"私信/客服";
    tool1.rightIcon = @"https://s.momocdn.com/w/u/others/2019/08/31/1567264720561-rightarrow.png";
    
    MLNGalleryMessageToolCellModel *tool2 = [[MLNGalleryMessageToolCellModel alloc] init];
    tool2.leftIcon = @"https://s.momocdn.com/w/u/others/2019/08/31/1567263950294-notice.png";
    tool2.title = @"官方通知";
    tool2.rightIcon = @"https://s.momocdn.com/w/u/others/2019/08/31/1567264720561-rightarrow.png";
    
    self.models = [@[tool1, tool2] mutableCopy];
}

- (void)loadMoreData
{
    NSDictionary *dataMap = [self readLocalFileWithName:@"message"];
    
    NSInteger code = [[dataMap objectForKey:@"code"] integerValue];
    if (code != 200) {
        return;
    }
    
    NSArray *dataArray = [dataMap objectForKey:@"data"];
    for (NSDictionary *itemDict in dataArray) {
        if ([itemDict isKindOfClass:[NSDictionary class]]) {
            MLNGalleryMessageDescCellModel *cellModel = [[MLNGalleryMessageDescCellModel alloc] initWithDict:itemDict];
            [self.models addObject:cellModel];
        }
    }
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
        [self.view addSubview:_mainView];
    }
    return _mainView;
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


// 读取本地JSON文件
- (NSDictionary *)readLocalFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

@end
