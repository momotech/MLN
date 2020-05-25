//
//  MLNDataBindModel.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/3/10.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNDataBindModel.h"

@implementation MLNDataBindModel

+ (instancetype)testModel {
    MLNDataBindModel *model = [MLNDataBindModel new];
    model.name = @"name";
    model.title = @"title";
    model.detail = @"detail";
    model.hideIcon = NO;
    model.iconUrl = @"http://img0.imgtn.bdimg.com/it/u=383546810,2079334210&fm=26&gp=0.jpg";
    model.type = @"Cell_1";
    
    NSMutableArray *arr = @[].mutableCopy;
    for (int i=0; i<5; i++) {
        MLNDataBindModel *m = [MLNDataBindModel new];
        m.name = [NSString stringWithFormat:@"name %d",i];
        m.title = [NSString stringWithFormat:@"title %d",i];
        [arr addObject:m];
    }
    model.source = arr;
    return model;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@" name: %@ \n title: %@ \n detail: %@ \n hideIcon: %d \n iconUrl: %@ \n", self.name, self.title, self.detail, self.hideIcon, self.iconUrl];
}


@end

@implementation MLNDatabindTableViewModel

+ (instancetype)testModel {
    MLNDatabindTableViewModel *m = [MLNDatabindTableViewModel new];
    m.source = @[].mutableCopy;
    m.tableHeight = 1000;
    return m;
}

@end

@implementation MLNDataBindArrayModel

+ (instancetype)testModel {
    MLNDataBindArrayModel *m = [MLNDataBindArrayModel new];
    m.name = @"main name";
    NSMutableArray *arr = @[].mutableCopy;
    for (int i = 0; i < 3; i++) {
        MLNDataBindModel *n = [MLNDataBindModel testModel];
        [arr addObject:n];
    }
    m.source = arr;
    return m;
}

@end
