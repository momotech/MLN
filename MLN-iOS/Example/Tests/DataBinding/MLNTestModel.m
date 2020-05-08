//
//  MLNTestModel.m
//  MLN_Tests
//
//  Created by Dai Dongpeng on 2020/3/5.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNTestModel.h"
#import "NSObject+MLNKVO.h"
@import ObjectiveC;

@implementation MLNTestModel
- (void)dealloc {
    Class cls = object_getClass(self);
    NSLog(@"%s %@",__func__,cls);
}
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

@implementation MLNTestReflectModel

- (NSDictionary *)mln_toDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.title forKey:@"title"];
    [dic setValue:@(self.count) forKey:@"count"];
    [dic setValue:self.color forKey:@"color"];
    [dic setValue:@(self.rect) forKey:@"rect"];
    return dic.copy;
}

@end


@implementation MLNCombineModel

- (void)dealloc {
    Class cls = object_getClass(self);
    NSLog(@"%s %@",__func__,cls);
}
@end
