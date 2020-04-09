//
//  MLNReflectTests.m
//  MLN_Tests
//
//  Created by Dai Dongpeng on 2020/4/9.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNTestModel.h"
#import <NSObject+MLNKVO.h>

SpecBegin(Reflect)

__block MLNTestChildModel *model;
__block MLNTestModel *tModel;
beforeEach(^{
           model = [MLNTestChildModel model];
           tModel = [MLNTestModel new];
           tModel.open = true;
           tModel.text = @"tt";
           });

context(@"Dictionary", ^{
        __block NSArray *set;
        __block NSDictionary *dic;
    beforeEach(^{
        set = [model.class mln_propertyKeys];
        dic = [model mln_toDictionary];
    });
    it(@"properties", ^{
       expect(set.count == 1).to.beTruthy();
       expect([set containsObject:@"name"]).to.beTruthy();
       
       set = [MLNTestModel mln_propertyKeys];
       expect(set.count == 2).to.beTruthy();
       expect([set containsObject:@"open"]).to.beTruthy();
       expect([set containsObject:@"text"]).to.beTruthy();
    });

    it(@"dictionary", ^{
       expect(dic.count == 1).to.beTruthy();
       expect(dic[@"name"]).equal(@"nn");
       dic = [tModel mln_toDictionary];
    });
});



SpecEnd
