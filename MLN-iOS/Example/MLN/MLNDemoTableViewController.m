//
//  ViewController.m
//  tableview
//
//  Created by xindong on 2018/11/1.
//  Copyright © 2018年 xindong. All rights reserved.
//

#import "MLNDemoTableViewController.h"
#import <ArgoUIViewLoader.h>

#define DLog(fmt, ...) NSLog(@"==>>"fmt, ##__VA_ARGS__)

#define USE_YYLABLE 0

#define APPEND_DATA_COUNT 5
#define FONT_SIZE 15
#define ROW_HEIGHT 200

@interface MLNDemoTableViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *cellItems;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UITableViewCell *> *calculCells;

@end

@implementation MLNDemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i < 20; i++) {
        NSDictionary *dic = @{@"title": [NSString stringWithFormat:@"text %d", i]};
        [self.cellItems addObject:dic];
    }
    [self createSubviews];
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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView *content = [cell viewWithTag:2021];
    
//    NSDictionary *dic = [self.cellItems objectAtIndex:indexPath.row];
//    [ArgoUIViewLoader updateData:dic forView:content autoWire:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

        UIView *content = [ArgoUIViewLoader loadViewFromLuaFilePath:@"MyCell.lua" modelKey:@"model"];
        content.tag = 2021;
        [cell.contentView addSubview:content];
        NSDictionary *dic = [self.cellItems objectAtIndex:indexPath.row];
        [ArgoUIViewLoader updateData:dic forView:content autoWire:YES];
        
        [ArgoUIViewLoader dataUpdatedCallbackForView:content callback:^(NSString * _Nonnull keyPath, id  _Nonnull newValue) {
            NSIndexPath *currentIndexPath = [tableView indexPathForCell:cell];
            NSLog(@"keyPath: %@ == newValue: %@ ==> indexPath: [%@-%@]", keyPath, newValue, @(currentIndexPath.section), @(currentIndexPath.row));
            NSString *key = [[keyPath componentsSeparatedByString:@"."] lastObject];
            NSDictionary *newDic = @{key: [newValue stringByAppendingFormat:@"%@", @(currentIndexPath.row)]};
            [self.cellItems replaceObjectAtIndex:currentIndexPath.row withObject:newDic];
        }];
    }
    
    NSDictionary *model = [self.cellItems objectAtIndex:indexPath.row];
    [ArgoUIViewLoader updateData:model forView:[cell.contentView viewWithTag:2021] autoWire:NO];
    
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
