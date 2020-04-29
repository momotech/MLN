//
//  MLNBlockKVOTests.m
//  MLN_Tests
//
//  Created by Dai Dongpeng on 2020/4/29.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MLNTestModel.h"
#import "NSObject+MLNKVO.h"

SpecBegin(BlockKVO)

__block MLNCombineModel *model;
__block __weak  MLNTestModel *weakTmodel;

context(@"Block", ^{
        __block BOOL r1 = NO;
        __block BOOL r2 = NO;
        __block BOOL r3 = NO;
        __block BOOL r4 = NO;
        NSString *newText = @"tt2";

beforeEach(^{
    r1 = r2 = r3 = r4 = NO;
    model = [MLNCombineModel new];
    MLNTestModel *tModel = [MLNTestModel new];
    tModel.open = true;
    tModel.text = @"tt";
    model.tm = tModel;
    model.name = @"name";
    weakTmodel = tModel;
});
        
    it(@"mln_observe", ^{
//    __weak typeof (self) wself = self;
    __weak typeof(model) weakModel = model;
    [self mln_observeObject:model property:@"tm.text" withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue) {
        r1 = YES;
        NSLog(@"%@",model.tm);
        expect(oldValue).equal(@"tt");
        expect(newValue).equal(newText);
        
        expect(observer == self).beTruthy();
        expect(object == weakModel).beTruthy();
    }];
    [self mln_observeObject:model property:@"tm.text" withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue) {
        r2 = YES;
        NSLog(@"%@",model.tm);
        expect(oldValue).equal(@"tt");
        expect(newValue).equal(newText);
        
        expect(observer == self).beTruthy();
        expect(object == weakModel).beTruthy();
    }];
    
    [self mln_observeObject:model.tm property:@"text" withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue) {
        r3 = YES;
        NSLog(@"%@",model.tm);
        expect(oldValue).equal(@"tt");
        expect(newValue).equal(newText);
        
        expect(observer == self).beTruthy();
        expect(object == weakModel.tm).beTruthy();
    }];
    
    [self mln_observeObject:model.tm property:@"text" withBlock:^(id  _Nonnull observer, id  _Nonnull object, id  _Nonnull oldValue, id  _Nonnull newValue) {
        r4 = YES;
        NSLog(@"%@",model.tm);
        expect(oldValue).equal(@"tt");
        expect(newValue).equal(newText);
        
        expect(observer == self).beTruthy();
        expect(object == weakModel.tm).beTruthy();
    }];
    
        weakTmodel.text = @"tt2";

    });
    
    it(@"mln_watch", ^{
model.mln_watch(@"tm.text", ^(id  _Nonnull oldValue, id  _Nonnull newValue) {
    r1 = YES;
    NSLog(@"%@",model.tm);

    expect(oldValue).equal(@"tt");
    expect(newValue).equal(newText);
});
model.mln_watch(@"tm.text", ^(id  _Nonnull oldValue, id  _Nonnull newValue) {
    r2 = YES;
    NSLog(@"%@",model.tm);

    expect(oldValue).equal(@"tt");
    expect(newValue).equal(newText);
});

model.tm.mln_watch(@"text", ^(id  _Nonnull oldValue, id  _Nonnull newValue) {
    r3 = YES;
    NSLog(@"%@",model.tm);

    expect(oldValue).equal(@"tt");
    expect(newValue).equal(newText);
});
model.tm.mln_watch(@"text", ^(id  _Nonnull oldValue, id  _Nonnull newValue) {
    r4 = YES;
    NSLog(@"%@",model.tm);

    expect(oldValue).equal(@"tt");
    expect(newValue).equal(newText);
});
model.tm.text = newText;
});
    
    it(@"mln_properties", ^{
    
    __weak typeof(model) weakModel = model;
    [self mln_observeObject:model properties:@[@"tm.text", @"name"] withBlock:^(id  _Nonnull observer, id  _Nonnull object, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue) {
        expect(self == observer);
        expect(weakModel == object);
        
        if([keyPath isEqualToString:@"tm.text"]) {
            r1 = r2 = YES;
            expect(oldValue).equal(@"tt");
            expect(newValue).equal(@"tt2");
        } else if ([keyPath isEqualToString:@"name"]) {
            r3 = r4 = YES;
            expect(oldValue).equal(@"name");
            expect(newValue).equal(@"name2");
        }
    }];
    
    model.tm.text = @"tt2";
    model.name = @"name2";
    });
afterEach(^{
    expect(r1).beTruthy();
    expect(r2).beTruthy();
    expect(r3).beTruthy();
    expect(r4).beTruthy();
    model = nil;
});
});



SpecEnd
