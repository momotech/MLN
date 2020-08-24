//
//  MLNPerformanceTestController.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/4/7.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNPerformanceTestController.h"
#import "MLNUIViewController.h"
#import "MLNLuaBundle.h"
//#import "MLNKitInstanceFactory.h"
#import <os/signpost.h>
#import "MLNUIKitInstanceFactory.h"

@interface MLNPerformanceTestController () <UITableViewDelegate, UITableViewDataSource> {
    os_log_t _luaPerfUseCache;
    os_log_t _luaPerfNOCache;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *demoArray;

@end

@implementation MLNPerformanceTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self tableView];
    _luaPerfUseCache = os_log_create("LuaPerformance", "LuaPerformance_UseCache");
    _luaPerfNOCache = os_log_create("LuaPerformance", "LuaPerformance_NOCache");

    NSString *title = [self useLuaCoreCache] ?  @"使用LuaCore缓存" : @"不使用LuaCore缓存";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemAction:)];
    self.navigationItem.rightBarButtonItem = item;
}

- (BOOL)useLuaCoreCache {
    NSMutableArray *corePool = [[MLNUIKitInstanceFactory defaultFactory] valueForKeyPath:@"luaCorePool.luaCoreQueue"];
    return corePool != nil;
}

- (void)setUseLuaCoreCache:(BOOL)use {
//    [[MLNKitInstanceFactory defaultFactory] setValue:use ? @[].mutableCopy : nil forKeyPath:@"luaCorePool.luaCoreQueue"];
//    [[MLNKitInstanceFactory defaultFactory] setValue:use? @(1) : @(0) forKeyPath:@"luaCorePool.capacity"];
    
    [[MLNUIKitInstanceFactory defaultFactory] setValue:use ? @[].mutableCopy : nil forKeyPath:@"luaCorePool.luaCoreQueue"];
    [[MLNUIKitInstanceFactory defaultFactory] setValue:use? @(1) : @(0) forKeyPath:@"luaCorePool.capacity"];
}

- (void)barButtonItemAction:(UIBarButtonItem *)item {
    [self setUseLuaCoreCache:![self useLuaCoreCache]];
    NSString *title = [self useLuaCoreCache] ?  @"使用LuaCore缓存" : @"不使用LuaCore缓存";
    item.title = title;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = [self.demoArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *demoName = [self.demoArray objectAtIndex:indexPath.row];
    Class cls = NSClassFromString(demoName);
    
    BOOL useCache = [self useLuaCoreCache];
    os_log_t luaLoad = useCache ? _luaPerfUseCache : _luaPerfNOCache;
    os_signpost_id_t ident = os_signpost_id_generate(luaLoad);
    
    if (cls) {

        os_signpost_interval_begin(luaLoad, ident, "load", "%s",NSStringFromClass(cls).UTF8String);
        CFAbsoluteTime s = CFAbsoluteTimeGetCurrent();

        UIViewController *vc = [cls new];
        [vc view];
        
        CFAbsoluteTime cost = (CFAbsoluteTimeGetCurrent() -  s)  *  1000;
        os_signpost_interval_end(luaLoad, ident, "load", "%s",NSStringFromClass(cls).UTF8String);

        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f ms",cost];
        [tableView reloadData];

//        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    os_signpost_interval_begin(luaLoad, ident, "load", "%s",demoName.UTF8String);
    CFAbsoluteTime s = CFAbsoluteTimeGetCurrent();

     MLNUIViewController*viewController = [[MLNUIViewController alloc] initWithEntryFileName:demoName bundleName:@"inner_demo"];
//    MLNLuaBundle *bundle = [MLNLuaBundle mainBundleWithPath:@"inner_demo.bundle"];
//    [viewController changeCurrentBundle:bundle];
    [viewController view];
    
    CFAbsoluteTime cost = (CFAbsoluteTimeGetCurrent() -  s)  *  1000;
    os_signpost_interval_end(luaLoad, ident, "load", "%s",demoName.UTF8String);

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f ms",cost];
    [tableView reloadData];

//    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.alpha = 1.0;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.alpha = 0.f;
}

#pragma mark - getter
- (NSArray *)demoArray
{
    if (!_demoArray) {
        if (@available(iOS 12.0, *)) {
            _demoArray = @[
                           @"CollectionViewDemo.lua",
                           @"DialogDemo.lua",
                           @"EditTextViewDemo.lua",
                           @"LabelDemo.lua",
                           @"LinearLayoutDemo.lua",
                           @"TableViewDemo.lua",
                           @"ViewPagerDemo.lua",
                           @"WaterfallViewDemo.lua",
    //                       @"MLNDataBindHotReload",
                           @"MLNBindModelViewController",
                           @"MLNBindTableViewController",
                           @"UIViewController",
                           @"MLNUIViewController"
                           ];
        } else {
            _demoArray = @[];
        }
    }
    return _demoArray;
}

@end
