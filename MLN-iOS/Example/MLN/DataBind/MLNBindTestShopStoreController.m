//
//  MLNBindTestShopStoreController.m
//  LuaNative
//
//  Created by Dongpeng Dai on 2020/7/10.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNBindTestShopStoreController.h"
#import "MLNUIKit.h"
#import "GoodsData.h"
#import "GoodsDataList.h"

@interface MLNBindTestShopStoreController ()
@property (nonatomic, strong) GoodsData *tableModel;
@end

@implementation MLNBindTestShopStoreController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createController];
}

- (void)createController {
    NSString *demoName = @"shop_store_list.lua";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PerformanceDemoMUI" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    MLNUIViewController *viewController = [[MLNUIViewController alloc] initWithEntryFileName:demoName bundle:bundle];

    [self createModel];
    
    [viewController bindData:self.tableModel forKey:@"goodsData"];
    [viewController mlnui_addToSuperViewController:self frame:self.view.bounds];
}

- (void)createModel {
    GoodsData *gd = [GoodsData new];
    NSMutableArray *list = @[].mutableCopy;
    for (int i = 0; i < 10; i++) {
        GoodsDataList *item = [GoodsDataList new];
        item.img = @"https://hbimg.huabanimg.com/973de16798446890fc3b5f55a978db53c36059e619f83-5eeIuJ_fw658";
        item.name = [NSString stringWithFormat:@"饭 %d",i];
        item.discount = 7.9 + (i / 10);
        item.price = 20 + i * 10;
        item.num = 0;
        [list addObject:item];
    }
    gd.list = list;
    gd.totalPrice = 0;
    gd.totalNum = 0;
    self.tableModel = gd;
}
@end
