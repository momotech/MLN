//
//  MLNDatabindingTests.m
//  MLN_Tests
//
//  Created by Dai Dongpeng on 2020/3/5.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <MLNUIDataBinding.h>
#import "MLNTestModel.h"
#import <MLNUIKVOObserver.h>
#import <NSObject+MLNUIKVO.h>
#import "MLNUIViewController.h"
#import "MLNUIViewController+DataBinding.h"
//#import "MLNKitViewController+DataBinding.h"
#import "MLNUILuaBundle.h"
#import "MLNUIKitInstance.h"

SpecBegin(MLNDatabinding)

__block MLNUIDataBinding *dataBinding;
__block MLNTestModel *model;
__block MLNUIViewController *vc;


beforeEach(^{
           NSBundle *bundle = [NSBundle bundleForClass:[self class]];
           MLNUILuaBundle *luaB = [[MLNUILuaBundle alloc] initWithBundle:bundle];
//           vc = [[MLNUIViewController alloc] initWithEntryFilePath:@"DataBindTest.lua"];
//           [vc changeCurrentBundle:luaB];
           vc = [[MLNUIViewController alloc] initWithEntryFileName:@"DataBindTest.lua" bundle:bundle];
           [vc view];
           
           dataBinding = [vc mlnui_dataBinding];
           [MLNUIDataBinding performSelector:NSSelectorFromString(@"mlnui_updateCurrentLuaCore:") withObject:vc.kitInstance.luaCore];
           
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
   NSArray *source = [MLNUIDataBinding performSelector:NSSelectorFromString(@"luaui_dataForKeys:") withObject:@"userData.source"];
   
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
   UIColor *c= [last[@"color"] mlnui_rawNativeData];
   expect(c).equal([UIColor redColor]);
   NSValue *v = @([last[@"rect"] CGRectValue]);
   expect(v).equal(@(CGRectMake(10, 10, 11, 11)));
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

it(@"observer", ^{
     __block BOOL result = NO;
     __block BOOL result2 = NO;
     void (^observerBlock)(NSString *,NSString *,id,id,id) = ^(NSString *keypath,NSString *key, id old, id new, dispatch_block_t com) {
         result = NO;
         result2 = NO;
         MLNUIKVOObserver *open = [[MLNUIKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
             expect(keyPath).to.equal(keypath);
             expect([change objectForKey:NSKeyValueChangeNewKey]).to.equal(new);
             expect([change objectForKey:NSKeyValueChangeOldKey]).to.equal(old);
//             expect(object).to.equal(model);
             expect(result).to.beFalsy();
             result = YES;
             if(com) com();
         } keyPath:keypath];
         [dataBinding addMLNUIObserver:open forKeyPath:keypath];
         
         void (^kvoBlock)(id,id) = ^(id oldValue, id newValue) {
             expect(newValue).to.equal(new);
             expect(oldValue).to.equal(old);
             BOOL r = [key isEqualToString:@"text"] || [key isEqualToString:@"open"];
             expect(r).to.beTruthy();
             expect(result2).to.beFalsy();
             result2 = YES;
         };
         
         model.mlnui_subscribe(@"text", ^(id  _Nonnull oldValue, id  _Nonnull newValue, id observerdObject) {
             kvoBlock(oldValue, newValue);
             expect([observerdObject valueForKeyPath:@"text"]).equal(newValue);
         }).mlnui_subscribe(@"open", ^(id  _Nonnull oldValue, id  _Nonnull newValue, id observerdObject) {
             kvoBlock(oldValue, newValue);
         });
     };
         
         it(@"BOOL", ^{
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
         
         it(@"NSString", ^{
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
         MLNUIKVOObserver *ob1 = [[MLNUIKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            id new = change[NSKeyValueChangeNewKey];
            expect(new).equal(@"ttaa");
            expect(r1).beFalsy();
            r1  = YES;
         } keyPath:@"text"];
         MLNUIKVOObserver *ob2 = [[MLNUIKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
             id new = change[NSKeyValueChangeNewKey];
             expect(new).equal(@"ttaa");
             expect(r2).beFalsy();
             r2  = YES;
         } keyPath:@"text"];

         [dataBinding addMLNUIObserver:ob1 forKeyPath:@"userData.text"];
         [dataBinding addMLNUIObserver:ob2 forKeyPath:@"userData.text"];
         model.text  = @"ttaa";
       expect(r1).beTruthy();
       expect(r2).beTruthy();
});

SpecEnd

