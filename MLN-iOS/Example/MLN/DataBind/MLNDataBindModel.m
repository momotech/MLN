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
    return model;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@" name: %@ \n title: %@ \n detail: %@ \n hideIcon: %d \n iconUrl: %@ \n", self.name, self.title, self.detail, self.hideIcon, self.iconUrl];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}
@end
