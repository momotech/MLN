//
//  MLNBindTableViewController.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/3/17.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNBindTableViewController.h"
#import "MLNKit.h"
#import "MLNDataBindModel.h"

@interface MLNBindTableViewController ()
@property (nonatomic, strong) NSMutableArray *modelArray;
@end

@implementation MLNBindTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createController];
}

- (void)createController {
    NSString *demoName = @"layout_DataBindTable.lua";
    MLNKitViewController *viewController = [[MLNKitViewController alloc] initWithEntryFilePath:demoName];
    MLNLuaBundle *bundle = [MLNLuaBundle mainBundleWithPath:@"inner_demo.bundle"];
    [viewController changeCurrentBundle:bundle];
    
    [self createModelArray];
    [viewController.dataBinding bindArray:self.modelArray forKey:@"source"];
    [viewController addToSuperViewController:self frame:self.view.bounds];
}

- (void)createModelArray {
    NSMutableArray *arr = @[].mutableCopy;
    for (int i = 0; i < 2; i++) {
        MLNDataBindModel *model = [MLNDataBindModel testModel];
        [arr addObject:model];
    }
    
    arr.mln_resueIdBlock = ^NSString * _Nonnull(NSArray * _Nonnull items, NSUInteger section, NSUInteger row) {
        return @"Cell_1";
    };
    arr.mln_heightBlock = ^NSUInteger(NSArray * _Nonnull items, NSUInteger section, NSUInteger row) {
        return 120;
    };
    
    self.modelArray = arr;
    [self testModel];
}

- (void)testModel {
    static int cnt = 1;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return ;
        }
        if (self.modelArray.count < 5) {
            MLNDataBindModel *model = [MLNDataBindModel testModel];
            [self.modelArray addObject:model];
        } else {
            MLNDataBindModel *m = self.modelArray.firstObject;
            m.title = [NSString stringWithFormat:@"change title %d",cnt];
            m.name = [NSString stringWithFormat:@"change name %d",cnt];
            cnt++;
            [self.modelArray removeObjectAtIndex:0];
            [self.modelArray addObject:m];
        }

        [self testModel];
    });
}


@end
