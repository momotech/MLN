//
//  MLNDBTestModel.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/5/22.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNDBTestModel.h"

@implementation MLNDBTestItem

+ (instancetype)testItem {
    MLNDBTestItem *item = [MLNDBTestItem new];
    item.title = @"o_title";
    item.cnt = 1;
    return item;
}
@end

@implementation MLNDBTestModel
+ (instancetype)testModel {
    MLNDBTestModel *m = [MLNDBTestModel new];
    m.name = @"o_name";
    m.number = @1;
    m.color = [UIColor redColor];
    m.height = 66;
    m.flag = YES;
    
    NSMutableDictionary *dic = @{}.mutableCopy;
    NSMutableArray *arr = @[].mutableCopy;
    for (int i = 0; i < 3; i++) {
        MLNDBTestItem *item1 = [MLNDBTestItem testItem];
        MLNDBTestItem *item2 = [MLNDBTestItem testItem];
        NSString *key = [NSString stringWithFormat:@"key_%d",i];
        [dic setObject:item1 forKey:key];
        [arr addObject:item2];
    }
    m.map = dic;
    m.list = arr;
    
    NSMutableArray *list2 = @[].mutableCopy;
    for (int i = 0; i < 2; i++) {
        NSMutableArray *arr = @[].mutableCopy;
        for (int j = 0; j < 2; j++) {
            MLNDBTestItem *item = [MLNDBTestItem testItem];
            [arr addObject:item];
        }
        [list2 addObject:arr];
    }
    m.list2 = list2;
    return m;
}
@end
