//
//  MLNArrayBindingTests.m
//  MLN_Tests
//
//  Created by Dai Dongpeng on 2020/3/5.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <MLNDataBinding.h>
#import <MLNKVOObserver.h>
#import "MLNTestModel.h"
#import <NSMutableArray+MLNKVO.h>

SpecBegin(ArrayBinding)

// fixed XCTest issue.
[NSMutableArray load];

__block MLNDataBinding *dataBinding;
__block NSMutableArray *modelsArray;

beforeEach(^{
    modelsArray = [NSMutableArray array];
    for(int i=0; i<10; i++) {
        MLNTestModel *m = [MLNTestModel new];
        m.open = i % 2;
        m.text = [NSString stringWithFormat:@"hello %d", i+10];
        [modelsArray addObject:m];
    }
    dataBinding = [[MLNDataBinding alloc] init];
    [dataBinding bindArray:modelsArray forKey:@"models"];
});

describe(@"observer", ^{
    __block BOOL result = NO;
    
    void(^observerBlock)(NSKeyValueChange, NSIndexSet *) = ^(NSKeyValueChange type, NSIndexSet *indexSet){
        result = NO;
        MLNKVOObserver *obs = [[MLNKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
            expect(@(kind)).to.equal(@(type));
            
            NSArray *arr = (NSArray *)object;
            expect(arr).to.beKindOf([NSArray class]);
            
            NSIndexSet *set = [change objectForKey:NSKeyValueChangeIndexesKey];
            expect(set).to.equal(set);
            
            expect(result).to.beFalsy();
            result = YES;
        } keyPath:@"models"];
        
        [dataBinding addArrayObserver:obs forKey:@"models"];
    };
    
    void(^testCaseBlock)(dispatch_block_t exeBlock, NSUInteger expectedCount) = ^(dispatch_block_t exeBlock, NSUInteger expectedCount) {
        observerBlock(NSKeyValueChangeInsertion, [NSIndexSet indexSetWithIndex:modelsArray.count]);
        exeBlock();
        expect(modelsArray.count == expectedCount).to.beTruthy();
        expect(result).to.beTruthy();
    };
    
    it(@"addObject", ^{
        testCaseBlock(^{
            [modelsArray addObject:@"abc"];
        }, modelsArray.count + 1);
    });
    it(@"insertObject", ^{
        testCaseBlock(^{
            [modelsArray insertObject:@"000" atIndex:0];
        }, modelsArray.count + 1);
    });
    
    afterEach(^{
        NSLog(@"%@",modelsArray);
    });
});

SpecEnd
