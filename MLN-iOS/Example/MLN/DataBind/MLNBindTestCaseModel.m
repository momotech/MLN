//
//  MLNBindTestCaseModel.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/5/13.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNBindTestCaseModel.h"

@implementation MLNBindTestCaseModel

+ (instancetype)testModel {
    MLNBindTestCaseModel *m = [MLNBindTestCaseModel getModel];
    
    NSMutableArray *marr = @[].mutableCopy;
    NSMutableDictionary *mdic = @{}.mutableCopy;
    for (int i = 0; i < 3; i++) {
        MLNBindTestCaseModel *tmp = [MLNBindTestCaseModel getModel];
        [marr addObject:tmp];
        
        tmp = [MLNBindTestCaseModel getModel];
        [mdic setObject:tmp forKey:[NSString stringWithFormat:@"key_%d",i]];
    }
    m.array = marr.copy;
    m.marray = marr;
    m.mdic = mdic;
    m.dic = mdic.copy;
    return m;
}

+ (instancetype)getModel {
    MLNBindTestCaseModel *m = [MLNBindTestCaseModel new];
    m.str = @"str";
    m.number = @(11);
    m.color = [UIColor redColor];
    m.flag = YES;
    m.num_i = 2;
    m.num_f = 2.3;
    m.num_cf = 2.4;
    CGRect r = CGRectMake(1.1, 1.2, 1.3, 1.4);
    CGPoint p = CGPointMake(2.1, 2.2);
    CGSize s = CGSizeMake(3.1, 3.2);
    m.rect = r;
    m.size = s;
    m.point = p;
    
    m.value_rect = @(r);
    m.value_size = @(s);
    m.value_point = @(p);
    return m;
}

@end

@implementation MLNBindTestCaseModel2

+ (instancetype)testModel {
    MLNBindTestCaseModel2 *m = [MLNBindTestCaseModel2 new];
    m.info = @"向好友介绍自己";
    m.tagArray = @[
        @[@"设计师", UIColor.redColor],
        @[@"程序员", UIColor.blueColor],
        @[@"勤劳的", UIColor.darkGrayColor]
    ];
    return m;
}

@end
