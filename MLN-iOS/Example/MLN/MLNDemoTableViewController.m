//
//  ViewController.m
//  tableview
//
//  Created by xindong on 2018/11/1.
//  Copyright © 2018年 xindong. All rights reserved.
//

#import "MLNDemoTableViewController.h"
#import <MLNUIKitViewController.h>
#import <MLNUIKitInstance.h>
#import <MLNUIViewController+DataBinding.h>
#import <MLNUIDataBinding.h>
#import <ArgoObservableMap.h>
#import <MLNUIModelHandler.h>

#define DLog(fmt, ...) NSLog(@"==>>"fmt, ##__VA_ARGS__)

#define USE_YYLABLE 0

#define APPEND_DATA_COUNT 5
#define FONT_SIZE 15
#define ROW_HEIGHT 200

@interface MyView : UIView

@end

@implementation MyView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
}

- (void)willRemoveSubview:(UIView *)subview {
    NSLog(@"subview: %@", subview);
    [super willRemoveSubview:subview];
}

@end

static NSString * kCellIdentifier = @"cell";

@interface MLNDemoTableViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *cellItems;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UITableViewCell *> *calculCells;

@property (nonatomic, strong) MLNUIKitViewController *kitVC;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUIKitViewController *> *vmReusePool;

@end

@implementation MLNDemoTableViewController

- (NSMutableDictionary<NSString *,MLNUIKitViewController *> *)vmReusePool {
    if (!_vmReusePool) {
        _vmReusePool = [NSMutableDictionary dictionary];
    }
    return _vmReusePool;
}

- (MLNUIKitViewController *)kitVC {
    if (!_kitVC) {
        _kitVC = [[MLNUIKitViewController alloc] initWithEntryFilePath:@"MyCell"];
    }
    return _kitVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i < 20; i++) {
//        NSDictionary *model = @{@"title":[NSString stringWithFormat:@"text %d", i]};
        
        NSDictionary *dic = @{@"title":[NSString stringWithFormat:@"text %d", i]};
        ArgoObservableMap *model = [ArgoObservableMap new];
        [model setObject:[NSString stringWithFormat:@"text %d", i] forKey:@"title"];
//        NSDictionary *model = @{@"title": [NSString stringWithFormat:@"text %d", i]};
//        [self.cellItems addObject:model];
//        [model setDictionary:dic];
        [self.cellItems addObject:model];
    }
    [self createSubviews];
}

static NSString *DISGUISE(id value) {
    return [NSString stringWithFormat:@"%p", value];
}

- (MLNUIKitViewController *)kitVCFromReusePool:(UITableViewCell *)cell {
    MLNUIKitViewController *vc = [self.vmReusePool objectForKey:DISGUISE(cell)];
    if (!vc) {
        vc = [[MLNUIKitViewController alloc] initWithEntryFilePath:@"MyCell.lua"];
        NSLog(@"---->>> create vm: %@ === cell: %p", vc, cell);
        [self.vmReusePool setObject:vc forKey:DISGUISE(cell)];
    }
    return vc;
}

#pragma mark - UITableView

- (void)createSubviews {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击第 %ld 个cell", indexPath.row + 1);
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView *content = [cell viewWithTag:2021];
    
    ArgoObservableMap *model = [self.cellItems objectAtIndex:indexPath.row - 1];
    [ArgoUIViewLoader updateData:model forView:content autoWire:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
//        MLNUIKitViewController *kitVC = [self kitVCFromReusePool:cell];
//        NSDictionary *model = [self.cellItems objectAtIndex:indexPath.row];
//        [kitVC.mlnui_dataBinding bindData:model forKey:@"model"];
//
//        UIView *content = [[[[kitVC view] subviews] firstObject] subviews].firstObject;
//        NSLog(@"******++>> %@", kitVC.view);
//        [cell.contentView addSubview:content];
        

        UIView *content = [ArgoUIViewLoader loadViewFromLuaFilePath:@"MyCell.lua" withModelKey:@"model" observer:^(NSString *_Nonnull key, id _Nonnull newValue) {
            
        }];

        content.tag = 2021;
        [cell.contentView addSubview:content];
        NSDictionary *model = [self.cellItems objectAtIndex:indexPath.row];
        [ArgoUIViewLoader updateData:model forView:content autoWire:NO];
    }
    
//    NSDictionary *model = [self.cellItems objectAtIndex:indexPath.row];
//    [ArgoUIViewLoader updateData:model forView:[cell.contentView viewWithTag:2021]];
    
    return cell;
}

#pragma mark - Lazy Loading

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height - 120)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = ROW_HEIGHT;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0.0;
        _tableView.estimatedSectionFooterHeight = 0.0;
//        _tableView.backgroundColor = [UIColor greenColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}

- (NSMutableArray<NSDictionary *> *)cellItems {
    if (!_cellItems) {
        _cellItems = [NSMutableArray array];
    }
    return _cellItems;
}

- (NSMutableDictionary<NSString *, UITableViewCell *> *)calculCells
{
    if (!_calculCells) {
        _calculCells = [NSMutableDictionary dictionary];
    }
    return _calculCells;
}
    

@end
