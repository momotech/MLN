//
//  MLNDatabindingTests.m
//  MLN_Tests
//
//  Created by Dai Dongpeng on 2020/3/5.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <MLNDataBinding.h>
#import "MLNTestModel.h"
#import <MLNKVOObserver.h>
#import <NSObject+MLNKVO.h>
#import "MLNUIViewController.h"
#import "MLNUIViewController+DataBinding.h"
//#import "MLNKitViewController+DataBinding.h"
#import "MLNLuaBundle.h"
#import "MLNKitInstance.h"

SpecBegin(MLNDatabinding)

__block MLNDataBinding *dataBinding;
__block MLNTestModel *model;
__block MLNUIViewController *vc;


beforeEach(^{
           NSBundle *bundle = [NSBundle bundleForClass:[self class]];
           MLNLuaBundle *luaB = [[MLNLuaBundle alloc] initWithBundle:bundle];
//           vc = [[MLNUIViewController alloc] initWithEntryFilePath:@"DataBindTest.lua"];
//           [vc changeCurrentBundle:luaB];
           vc = [[MLNUIViewController alloc] initWithEntryFileName:@"DataBindTest.lua" bundle:bundle];
           [vc view];
           
           dataBinding = [vc mln_dataBinding];
           [MLNDataBinding performSelector:NSSelectorFromString(@"mln_updateCurrentLuaCore:") withObject:vc.kitInstance.luaCore];
           
           model = [MLNTestModel new];
           model.open = true;
           model.text =  @"init";
           NSMutableArray *s = [NSMutableArray array];
           for(int i = 0; i < 9; i++) {
               MLNTestChildModel *m = [MLNTestChildModel model];
               [s addObject:m];
           }
           MLNTestReflectModel *m = [MLNTestReflectModel new];
           m.title = @"title";
           m.count = 11;
           m.color = [UIColor redColor];
           m.rect = CGRectMake(10, 10, 11, 11);
           [s addObject:m];
           
           model.source = s;
           [dataBinding bindData:model forKey:@"userData"];
        
    });

it(@"get data", ^{
   expect([dataBinding dataForKeyPath:@"userData.open"]).to.equal(@(true));
   expect([dataBinding dataForKeyPath:@"userData.text"]).to.equal(@"init");
   expect([dataBinding dataForKeyPath:@"userData.isOpen"]).to.equal(@(true));
   });

it(@"get table data", ^{
   NSArray *source = [MLNDataBinding performSelector:NSSelectorFromString(@"lua_dataForKeyPath:") withObject:@"userData.source"];
   
   expect(source.count == 10).to.beTruthy();
   expect([source isKindOfClass:[NSArray class]]).to.beTruthy();
   expect([source isKindOfClass:[NSMutableArray class]]).to.beFalsy();
   NSDictionary *first = source.firstObject;
   
   expect([first isKindOfClass:[NSDictionary class]]).to.beTruthy();
   expect([first isKindOfClass:[NSMutableDictionary class]]).to.beFalsy();
   expect(first[@"name"]).equal(@"nn");
   
   NSDictionary *last = source.lastObject;
   expect([last isKindOfClass:[NSDictionary class]]).to.beTruthy();
   expect([last isKindOfClass:[NSMutableDictionary class]]).to.beFalsy();
   expect(last[@"title"]).equal(@"title");
   expect(last[@"count"]).equal(@(11));
   expect(last[@"color"]).equal([UIColor redColor]);
   expect(last[@"rect"]).equal(@(CGRectMake(10, 10, 11, 11)));
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
     __block BOOL result2 = NO;
     void (^observerBlock)(NSString *,NSString *,id,id,id) = ^(NSString *keypath,NSString *key, id old, id new, dispatch_block_t com) {
         result = NO;
         result2 = NO;
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
         
         void (^kvoBlock)(id,id) = ^(id oldValue, id newValue) {
             expect(newValue).to.equal(new);
             expect(oldValue).to.equal(old);
             BOOL r = [key isEqualToString:@"text"] || [key isEqualToString:@"open"];
             expect(r).to.beTruthy();
             expect(result2).to.beFalsy();
             result2 = YES;
         };
         
         model.mln_subscribe(@"text", ^(id  _Nonnull oldValue, id  _Nonnull newValue, id observerdObject) {
             kvoBlock(oldValue, newValue);
             expect([observerdObject valueForKeyPath:@"text"]).equal(newValue);
         }).mln_subscribe(@"open", ^(id  _Nonnull oldValue, id  _Nonnull newValue, id observerdObject) {
             kvoBlock(oldValue, newValue);
         });
     };
         
         context(@"BOOL", ^{
    beforeEach(^{
        observerBlock(@"userData.open", @"open", @(YES), @(NO),nil);
    });
    it(@"update", ^{
        [dataBinding updateDataForKeyPath:@"userData.open" value:@(false)];
        expect(result).to.beTruthy();
        expect(result2).to.beTruthy();
    });
    it(@"set", ^{
        model.open = false;
        expect(result).to.beTruthy();
        expect(result2).to.beTruthy();
    });
});
         
         context(@"NSString", ^{
    beforeEach(^{
        observerBlock(@"userData.text",@"text",@"init",@"word",nil);
    });
    it(@"update", ^{
        [dataBinding updateDataForKeyPath:@"userData.text" value:@"word"];
        expect(result).to.beTruthy();
        expect(result2).to.beTruthy();
    });
    it(@"set", ^{
        model.text = @"word";
        expect(result).to.beTruthy();
        expect(result2).to.beTruthy();
    });
});
});

it(@"observer_onc", ^{
         __block BOOL r1 = NO;
         __block BOOL r2 = NO;
         MLNKVOObserver *ob1 = [[MLNKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            id new = change[NSKeyValueChangeNewKey];
            expect(new).equal(@"ttaa");
            expect(r1).beFalsy();
            r1  = YES;
         } keyPath:@"text"];
         MLNKVOObserver *ob2 = [[MLNKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
             id new = change[NSKeyValueChangeNewKey];
             expect(new).equal(@"ttaa");
             expect(r2).beFalsy();
             r2  = YES;
         } keyPath:@"text"];

         [dataBinding addDataObserver:ob1 forKeyPath:@"userData.text"];
         [dataBinding addDataObserver:ob2 forKeyPath:@"userData.text"];
         model.text  = @"ttaa";
       expect(r1).beTruthy();
       expect(r2).beTruthy();
});

SpecEnd

