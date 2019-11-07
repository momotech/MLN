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

#define kMLNTabBarHeight 44

@interface MLNGalleryMessageViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MLNGalleryNavigationBar *navigationBar;

@property (nonatomic, strong) UITableView *mainView;

@property (nonatomic, strong) NSArray <MLNGalleryMessageBaseCellModel *>* models;

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
    MLNGalleryMessageToolCellModel *tool1 = [[MLNGalleryMessageToolCellModel alloc] init];
    tool1.leftIcon = @"https://s.momocdn.com/w/u/others/2019/08/31/1567263950353-service.png";
    tool1.title = @"私信/客服";
    tool1.rightIcon = @"https://s.momocdn.com/w/u/others/2019/08/31/1567264720561-rightarrow.png";
    
    MLNGalleryMessageToolCellModel *tool2 = [[MLNGalleryMessageToolCellModel alloc] init];
    tool2.leftIcon = @"https://s.momocdn.com/w/u/others/2019/08/31/1567263950294-notice.png";
    tool2.title = @"官方通知";
    tool2.rightIcon = @"https://s.momocdn.com/w/u/others/2019/08/31/1567264720561-rightarrow.png";
    
    MLNGalleryMessageDescCellModel *msg1 = [[MLNGalleryMessageDescCellModel alloc] init];
    msg1.avatar = @"";
    msg1.name = @"";
    msg1.time = @"";
    msg1.desc = @"关注了我";
    msg1.type = MLNGalleryMessageDescCellModelTypeAttentionYou;
    
    
    self.models = @[tool1, tool2];
    
    
    
    
    [self mainView];
    [self.mainView reloadData];
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


@end
