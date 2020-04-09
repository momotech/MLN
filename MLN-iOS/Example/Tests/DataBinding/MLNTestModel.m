//
//  MLNTestModel.m
//  MLN_Tests
//
//  Created by Dai Dongpeng on 2020/3/5.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNTestModel.h"

@implementation MLNTestModel


@end

@implementation MLNTestChildModel

+ (instancetype)model {
    MLNTestChildModel *m = [MLNTestChildModel new];
    m.text = @"tt";
    m.name = @"nn";
    m.open = YES;
    m->_num = @11;
    return m;
}
@end
