//
//  ArgoUIViewLoaderDemoController.m
//  LuaNative
//
//  Created by xindong on 2021/1/26.
//  Copyright © 2021 MoMo. All rights reserved.
//

#import "ArgoUIViewLoaderDemoController.h"
#import <ArgoUIViewLoader.h>
#import <MLNUILinkProtocol.h>

#define ROW_HEIGHT 300

@interface ArgoUIViewLoaderDemoController ()<UITableViewDelegate, UITableViewDataSource, MLNUILinkProtocol>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *cellItems;

@end

@implementation ArgoUIViewLoaderDemoController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i < 1; i++) {
        NSDictionary *dic = @{@"title": [NSString stringWithFormat:@"text %d", i]};
        [self.cellItems addObject:dic];
    }
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellItems.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击第 %ld 个cell", indexPath.row + 1);
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView *content = [cell viewWithTag:2021];
    
    // 在原生中修改数据中的某个字段，UI会自动更新
//    ArgoObservableMap *data = [ArgoUIViewLoader observableDataForView:content];
//    [data setObject:@"原生中修改了title" forKey:@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        NSError *error = nil;
        UIView *contentView = [ArgoUIViewLoader loadViewFromLuaFilePath:@"MyCell.lua" modelKey:@"model"];
        
        contentView.tag = 2021;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        [cell.contentView addSubview:contentView];
        
//        [self addLuaDataUpdatedCallback:contentView];
    }
    NSDictionary *model = [self.cellItems objectAtIndex:indexPath.row];
    NSNumber *model1 = @(100);
//    CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();
    [ArgoUIViewLoader updateData:model1 forView:[cell.contentView viewWithTag:2021] autoWire:NO];
//    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
//    NSLog(@"time cost: %0.2f ms", (end - begin) * 1000);
    return cell;
}

#pragma mark - 

// 点击绿色视图，lua中会修改 model.title 字段，进而会回调在这里
- (void)addLuaDataUpdatedCallback:(UIView *)contentView {
    __weak typeof(self) weakSelf = self;
    [ArgoUIViewLoader dataUpdatedCallbackForView:contentView callback:^(NSString *_Nonnull keyPath, id _Nonnull newValue) {
        NSLog(@"keyPath: %@ == newValue: %@", keyPath, newValue);
        // 将数据变更同步到原始数据源
        UITableViewCell *cell = (UITableViewCell *)[[contentView superview] superview];
        NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
        
        NSString *key = [[keyPath componentsSeparatedByString:@"."] lastObject];
        NSDictionary *newDic = @{key: newValue};
        [weakSelf.cellItems replaceObjectAtIndex:indexPath.row withObject:newDic];
    }];
}

#pragma mark - MLNUILinkProtocol

+ (UIViewController *)mlnLinkCreateController:(NSDictionary *)params closeCallback:(MLNUILinkCloseCallback)callback {
    ArgoUIViewLoaderDemoController *vc = [[ArgoUIViewLoaderDemoController alloc] init];
    return vc;
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

@end
