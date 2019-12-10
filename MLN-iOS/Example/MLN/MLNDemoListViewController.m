//
//  MLNDemoListViewController.m
//  LuaNative
//
//  Created by MOMO on 2019/12/7.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import "MLNDemoListViewController.h"
#import "MLNKitViewController.h"

@interface MLNDemoListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *demoArray;

@end

@implementation MLNDemoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self tableView];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate=  self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.demoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        cell = [tableView  dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = [self.demoArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *demoName = [self.demoArray objectAtIndex:indexPath.row];
    MLNKitViewController *viewController = [[MLNKitViewController alloc] initWithEntryFilePath:demoName];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.alpha = 0.0;
}

#pragma mark - getter
- (NSArray *)demoArray
{
    if (!_demoArray) {
        _demoArray = @[
                       @"ToastDemo.lua",
                       @"windowDemo.lua",
                       @"LoadingDemo.lua",
                       @"EditTextViewDemo.lua",
                       @"TableViewDemo.lua",
                       @"WaterfallViewDemo.lua",
                       @"DialogDemo.lua",
                       @"AlertDemo.lua",
                       @"SystemDemo.lua",
                       @"window-self-viewDisappear-functionDemo.lua",
                       @"StyleString-boolean-showAsImage-SizeDemo.lua",
                       @"CollectionViewDemo.lua",
                       @"TabSegmentViewDemo.lua",
                       @"View-boolean-goneDemo.lua",
                       @"ScrollViewDemo.lua",
                       @"AnimatorDemo.lua",
                       @"PreferenceUtilsDemo.lua",
                       @"LabelDemo.lua",
                       @"window-self-viewAppear-functionDemo.lua",
                       @"FileDemo.lua",
                       @"window-self-backKeyPressed-functionDemo.lua",
                       @"CollectionViewGridLayoutDemo.lua",
                       @"TimerDemo.lua",
                       @"View-self-requestLayoutDemo.lua",
                       @"ImageButtonDemo.lua",
                       @"SwitchDemo.lua",
                       @"LinearLayoutDemo.lua",
                       @"ViewPagerDemo.lua",
                       @"HttpDemo.lua",
                       ];
    }
    return _demoArray;
}

@end
