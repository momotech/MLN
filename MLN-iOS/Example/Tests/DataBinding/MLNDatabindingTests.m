//
//  MLNDatabindingTests.m
//  MLN_Tests
//
//  Created by Dai Dongpeng on 2020/3/5.
//  Copyright © 2020 liu.xu_1586. All rights reserved.
//

#import <MLNDataBinding.h>
#import "MLNTestModel.h"
#import <MLNKVOObserver.h>

SpecBegin(MLNDatabinding)

__block MLNDataBinding *dataBinding;
__block MLNTestModel *model;

beforeEach(^{
           dataBinding = [[MLNDataBinding alloc] init];
           model = [MLNTestModel new];
           model.open = true;
           model.text =  @"init";
           [dataBinding bindData:model forKey:@"userData"];
           });

it(@"get data", ^{
   expect([dataBinding dataForKeyPath:@"userData.open"]).to.equal(@(true));
   expect([dataBinding dataForKeyPath:@"userData.text"]).to.equal(@"init");
   expect([dataBinding dataForKeyPath:@"userData.isOpen"]).to.equal(@(true));
   });

it(@"update data", ^{
   [dataBinding updateDataForKeyPath:@"userData.open" value:@(false)];
   [dataBinding updateDataForKeyPath:@"userData.text" value:@"update"];
   
   expect(model.open).to.equal(@(false));
   expect(model.isOpen).to.equal(@(false));
   expect(model.text).to.equal(@"update");
   
   expect([dataBinding dataForKeyPath:@"userData.open"]).to.equal(@(false));
   expect([dataBinding dataForKeyPath:@"userData.text"]).to.equal(@"update");
   expect([dataBinding dataForKeyPath:@"userData.isOpen"]).to.equal(@(false));
});

describe(@"observer", ^{
     __block BOOL result = NO;
     void (^observerBlock)(NSString *,NSString *,id,id,id) = ^(NSString *keypath,NSString *key, id old, id new, dispatch_block_t com) {
         result = false;
         MLNKVOObserver *open = [[MLNKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
             expect(keyPath).to.equal(key);
             expect([change objectForKey:NSKeyValueChangeNewKey]).to.equal(new);
             expect([change objectForKey:NSKeyValueChangeOldKey]).to.equal(old);
             expect(object).to.equal(model);
             expect(result).to.beFalsy();
             result = YES;
             if(com) com();
         } keyPath:keypath];
         [dataBinding addDataObserver:open forKeyPath:keypath];
     };
         
         context(@"BOOL", ^{
    beforeEach(^{
        observerBlock(@"userData.open", @"open", @(YES), @(NO),nil);
    });
    it(@"update", ^{
        [dataBinding updateDataForKeyPath:@"userData.open" value:@(false)];
        expect(result).to.beTruthy();
    });
    it(@"set", ^{
        model.open = false;
        expect(result).to.beTruthy();
    });
});
         
         context(@"NSString", ^{
    beforeEach(^{
        observerBlock(@"userData.text",@"text",@"init",@"word",nil);
    });
    it(@"update", ^{
        [dataBinding updateDataForKeyPath:@"userData.text" value:@"word"];
        expect(result).to.beTruthy();
    });
    it(@"set", ^{
        model.text = @"word";
        expect(result).to.beTruthy();
    });
});
});

SpecEnd

