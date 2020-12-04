//
//  MLNDemoListViewController.m
//  LuaNative
//
//  Created by MOMO on 2019/12/7.
//  Copyright © 2019年 MoMo. All rights reserved.
//

#import "MLNDemoListViewController.h"
#import "MLNKitViewController.h"
#import "MLNLuaBundle.h"
#import "MLNUILuaBundle.h"
#import "MLNUIViewController.h"
#import "MLNUIBridge.h"
#import "ArgoUIKit.h"

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
    Class cls = NSClassFromString(demoName);
    if (cls) {
        UIViewController *vc = [cls new];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if ([demoName hasPrefix:@"Argo"]) {
        ArgoViewController *viewController = [[ArgoViewController alloc] initWithEntryFileName:demoName bundleName:@"inner_demo.bundle"];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        MLNKitViewController *viewController = [[MLNKitViewController alloc] initWithEntryFilePath:demoName];
        [viewController regClasses:@[[MLNUIBridge class]]];
        MLNLuaBundle *bundle = [MLNLuaBundle mainBundleWithPath:@"inner_demo.bundle"];
        [viewController changeCurrentBundle:bundle];
        [self.navigationController pushViewController:viewController animated:YES];
    }
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
//                       @"CustomHotReload.lua",
                       @"CollectionViewDemo.lua",
                       @"DialogDemo.lua",
                       @"EditTextViewDemo.lua",
                       @"LabelDemo.lua",
                       @"LinearLayoutDemo.lua",
                       @"TableViewDemo.lua",
                       @"ArgoTableViewCeilingCellDemo.lua",
                       @"ArgoTableViewZoomPictureDemo.lua",
                       @"ViewPagerDemo.lua",
                       @"WaterfallViewDemo.lua",
//                       @"MLNBindModelViewController",
//                       @"MLNBindTableViewController",
//                       @"MLNDataBindArrayViewController",
                       @"MLNBindTestShopStoreController",
                       @"MLNBindTestLayoutController",
                       @"MLNDataBindHotReload",
                       @"MLNPerformanceTestController",
                       @"MLNKuaController",
//                       @"MLNKuaControllerAsync",
//                       @"MLNViewPagerDemo",
                       @"DemoLiyifengViewController",
                       ];
    }
    return _demoArray;
}

@end
