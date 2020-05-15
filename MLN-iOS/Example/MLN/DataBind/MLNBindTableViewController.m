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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createController];
}

- (void)createController {
    NSString *demoName = @"layout_DataBindTable.lua";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"inner_demo" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    MLNUIViewController *viewController = [[MLNUIViewController alloc] initWithEntryFileName:demoName bundle:bundle];

    [self createModelArray];
    
    [viewController bindData:self.tableModel forKey:@"tableModel"];
    [viewController mln_addToSuperViewController:self frame:self.view.bounds];
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
    
//    tableModel.source.mln_subscribeItem(^(NSObject * _Nonnull item, NSString * _Nonnull keyPath, NSObject * _Nonnull oldValue, NSObject * _Nonnull newValue) {
//        NSLog(@"item  %@ keypath %@ old %@ new %@",item,keyPath,oldValue,newValue);
//    });
    [self mln_observeArray:self.tableModel.source withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
         NSLog(@"item  %@ old %@ new %@",object,oldValue,newValue);
    }];
    
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

@end
