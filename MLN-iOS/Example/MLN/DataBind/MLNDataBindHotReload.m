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
@property (nonatomic, strong) NSMutableArray <MLNDataBindModel *> *modelArray;
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
    
    arr.mln_resueIdBlock = ^NSString * _Nonnull(NSArray * _Nonnull items, NSUInteger section, NSUInteger row) {
        return @"Cell_1";
    };
    arr.mln_heightBlock = ^NSUInteger(NSArray * _Nonnull items, NSUInteger section, NSUInteger row) {
        return 150;
    };
    
    [self.dataBinding bindArray:arr forKey:@"source"];
    self.modelArray = arr;
    [self testModel];
}

- (void)testModel {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return ;
        }
        MLNDataBindModel *m = self.modelArray.firstObject;
        static int cnt = 1;
        m.title = [NSString stringWithFormat:@"title %d",cnt++];
        [self testModel];
    });
}

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
        [self.modelArray addObject:m];
        cnt++;
        [self testDataBind];
    });
}

- (void)dealloc {
    NSLog(@"---- dealloc : %s ",__func__);
}

@end
