//
//  MLNDataBindHotReload.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/3/10.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNDataBindHotReload.h"
#import "MLNStaticTest.h"
#import "MLNDataBindModel.h"
#import <NSArray+MLNKVO.h>

@interface MLNDataBindHotReload ()
@property (nonatomic, strong) MLNDataBindModel *model;
//@property (nonatomic, strong) NSMutableArray <MLNDataBindModel *> *modelArray;
@property (nonatomic, strong) MLNDatabindTableViewModel *tableModel;
@end

@implementation MLNDataBindHotReload

- (instancetype)init {
    self = [super initWithRegisterClasses:@[[MLNStaticTest class]] extraInfo:nil];
    if (self) {
        NSLog(@"---- %s",__FUNCTION__);
    }
    return self;
}

- (void)viewDidLoad {
    [self createModel];
    [self createModelArray];
//    [self testDataBind];
    
    [super viewDidLoad];
}

- (void)createModel {
    MLNDataBindModel *model = [MLNDataBindModel testModel];
    self.model = model;
    [self bindData:model forKey:@"userData"];
}

- (void)createModelArray {
    NSMutableArray *arr = @[].mutableCopy;
    for (int i = 0; i < 2; i++) {
        MLNDataBindModel *model = [MLNDataBindModel testModel];
        [arr addObject:model];
    }
    
    self.tableModel = [MLNDatabindTableViewModel testModel];
    NSMutableArray *models = @[arr].mutableCopy;
    self.tableModel.source = models;

    self.tableModel.source.mln_subscribeItem(^(NSObject * _Nonnull item, NSString * _Nonnull keyPath, NSObject * _Nullable oldValue, NSObject * _Nullable newValue) {
        NSLog(@"item  %@ keypath %@ old %@ new %@",item,keyPath,oldValue,newValue);
    });
    
//    [self.dataBinding bindArray:models forKey:@"source"];
    [self.dataBinding bindData:self.tableModel forKey:@"tableModel"];
    
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
        NSMutableArray *models = self.tableModel.source;
        if (models.mln_is2D) {
            if (models.count < 3) {
                MLNDataBindModel *model = [MLNDataBindModel testModel];
                model.name = [NSString stringWithFormat:@"section %zd",models.count];
                model.title = [NSString stringWithFormat:@"section %zd title %zd",models.count,models.count];
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
            [models removeObjectAtIndex:0];
            [models addObject:m];
        }
        
        [self testModel];

    });
}

//- (void)testModel {
//    __weak typeof(self) weakSelf = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        __strong typeof(weakSelf) self = weakSelf;
//        if (!self) {
//            return ;
//        }
//        MLNDataBindModel *m = self.modelArray.firstObject;
//        if ([m isKindOfClass:[NSMutableArray class]]) {
//            m = [(NSMutableArray *)m firstObject];
//        }
//        static int cnt = 1;
//        m.title = [NSString stringWithFormat:@"title %d",cnt++];
//        [self testModel];
//    });
//}

- (void)testDataBind {
    static int cnt = 1;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        self.model.hideIcon = !self.model.hideIcon;
        self.model.title = [NSString stringWithFormat:@"title %d",cnt];
        self.model.name = [NSString stringWithFormat:@"name %d",cnt];
        self.model.detail = [NSString stringWithFormat:@"detail %d",cnt];
        self.model.iconUrl = self.model.iconUrl;
        
        MLNDataBindModel *m = [MLNDataBindModel testModel];
        m.title = self.model.title;
        m.name = self.model.name;
        m.detail = self.model.detail;
        
        NSMutableArray *arr = self.tableModel.source.firstObject;
        if (![arr isKindOfClass:[NSMutableArray class]]) {
            arr = self.tableModel.source;
        }
        [arr addObject:m];
        cnt++;
        [self testDataBind];
    });
}

- (void)dealloc {
    NSLog(@"---- dealloc : %s ",__func__);
}

@end
