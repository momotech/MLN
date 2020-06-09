//
//  MLNReflectTests.m
//  MLN_Tests
//
//  Created by Dai Dongpeng on 2020/4/9.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNTestModel.h"
#import <NSObject+MLNUIKVO.h>
#import <NSObject+MLNUIReflect.h>

SpecBegin(Reflect)

__block MLNTestChildModel *model;
__block MLNTestModel *tModel;
beforeEach(^{
           model = [MLNTestChildModel model];
           tModel = [MLNTestModel new];
           tModel.open = true;
           tModel.text = @"tt";
           });

it(@"Dictionary", ^{
        __block NSArray *set;
        __block NSDictionary *dic;
    beforeEach(^{
        set = [model.class mlnui_propertyKeys];
        dic = [model mlnui_toDictionary];
    });
    it(@"properties", ^{
       expect(@(set.count)).equal(@1);
       expect([set containsObject:@"name"]).to.beTruthy();
       
       set = [MLNTestModel mlnui_propertyKeys];
       expect(@(set.count)).equal(@4);
       expect([set containsObject:@"open"]).to.beTruthy();
       expect([set containsObject:@"text"]).to.beTruthy();
       expect([set containsObject:@"source"]).to.beTruthy();
       expect([set containsObject:@"source2d"]).to.beTruthy();

    });

    it(@"to_dic", ^{
       expect(dic.count == 1).to.beTruthy();
       expect(dic[@"name"]).equal(@"nn");
       dic = [tModel mlnui_toDictionary];
    });
});



SpecEnd
