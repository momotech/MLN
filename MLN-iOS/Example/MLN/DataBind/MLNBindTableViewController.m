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
//@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) MLNDatabindTableViewModel *tableModel;
@end

@implementation MLNBindTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@">>>>mem alloc %@",self);
    }
    return self;
}

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
    
//    [viewController.dataBinding bindArray:self.modelArray forKey:@"source"];
    [viewController bindData:self.tableModel forKey:@"tableModel"];
    
    [viewController addToSuperViewController:self frame:self.view.bounds];
}

- (void)createModelArray {
    NSMutableArray *arr = @[].mutableCopy;
    for (int i = 0; i < 3; i++) {
        MLNDataBindModel *model = [MLNDataBindModel testModel];
        if (i == 0) {
            model.type = @"AD";
        }
        [arr addObject:model];
    }
    
    MLNDatabindTableViewModel *tableModel = [MLNDatabindTableViewModel testModel];
    tableModel.source = @[arr].mutableCopy;
    
    tableModel.source.mln_subscribeItem(^(NSObject * _Nonnull item, NSString * _Nonnull keyPath, NSObject * _Nonnull oldValue, NSObject * _Nonnull newValue) {
        NSLog(@"item  %@ keypath %@ old %@ new %@",item,keyPath,oldValue,newValue);
    });
    
    self.tableModel =  tableModel;
    [self testModel];
}

//- (void)testModel {
//    static int cnt = 1;
//    __weak typeof(self) weakSelf = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        __strong typeof(weakSelf) self = weakSelf;
//        if (!self) {
//            return ;
//        }
//        NSMutableArray *models = self.tableModel.source;
//        if (models.count < 5) {
//            MLNDataBindModel *model = [MLNDataBindModel testModel];
//            [models addObject:model];
//        } else {
//            MLNDataBindModel *m = models.firstObject;
//            m.title = [NSString stringWithFormat:@"change title %d",cnt];
//            m.name = [NSString stringWithFormat:@"change name %d",cnt];
//            cnt++;
//            [models removeObjectAtIndex:0];
//            [models addObject:m];
//        }
//
//        [self testModel];
//    });
//}

- (void)testModel {
    static int cnt = 1;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return ;
        }
        NSMutableArray *models = self.tableModel.source;
        if (models.mln_is2D) {
            if (models.count < 3) {
                MLNDataBindModel *model = [MLNDataBindModel testModel];
                model.name = [NSString stringWithFormat:@"section %zd",models.count];
                model.title = [NSString stringWithFormat:@"section %zd title",models.count];
                [models addObject:@[model]];
            }
            
            models = [models firstObject];
        }
        if (models.count < 5) {
            MLNDataBindModel *model = [MLNDataBindModel testModel];
            [models addObject:model];
        } else {
            MLNDataBindModel *m = models.firstObject;
            m.title = [NSString stringWithFormat:@"change title %d",cnt];
            m.name = [NSString stringWithFormat:@"change name %d",cnt];
            cnt++;
            if (cnt % 2) {
                [models removeObjectAtIndex:0];
                [models addObject:m];
            } else {
                [models replaceObjectAtIndex:0 withObject:m];
            }

        }
        
        [self testModel];
    });
}

- (void)dealloc {
    NSLog(@">>>>mem dealloc %@",self);
}
@end
