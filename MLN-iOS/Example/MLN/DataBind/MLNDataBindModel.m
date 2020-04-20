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
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@">>>>me_model alloc %@",self);
    }
    return self;
}

- (void)dealloc {
    NSLog(@">>>>me_model dealloc %@",self);
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@">>>>me_model alloc %@",self);
    }
    return self;
}

- (void)dealloc {
    NSLog(@">>>>me_model dealloc %@",self);
}

@end
