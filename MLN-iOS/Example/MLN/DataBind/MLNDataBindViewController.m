//
//  MLNDataBindViewController.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/3/10.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNDataBindViewController.h"
#import "MLNStaticTest.h"
#import "MLNDataBindModel.h"
#import <NSArray+MLNKVO.h>

@interface MLNDataBindViewController ()
@property (nonatomic, strong) MLNDataBindModel *model;
@property (nonatomic, strong) NSMutableArray <MLNDataBindModel *> *modelArray;
@end

@implementation MLNDataBindViewController

- (instancetype)init {
    self = [super initWithRegisterClasses:@[[MLNStaticTest class]] extraInfo:nil];
    if (self) {
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
}

- (void)testDataBind {
    static int cnt = 1;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        self.model.open = !self.model.open;
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
