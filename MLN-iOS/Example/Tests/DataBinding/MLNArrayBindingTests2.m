
#import <MLNDataBinding.h>
#import <MLNKVOObserver.h>
#import "MLNTestModel.h"
#import <NSMutableArray+MLNKVO.h>
#import "NSObject+MLNKVO.h"

SpecBegin(ArrayBinding2)

// fixed XCTest issue.
//[NSMutableArray load];

__block MLNDataBinding *dataBinding;
__block MLNTestModel *model;
__block NSMutableArray *modelsArray;
NSString *arrayKeyPath = @"userData.source";
NSString *arrayKeyPath2 = @"userData.source2d";

beforeEach(^{
    NSMutableArray *array = [NSMutableArray array];
    for(int i=0; i<10; i++) {
        MLNTestModel *m = [MLNTestModel new];
        m.open = i % 2;
        m.text = [NSString stringWithFormat:@"hello %d", i+10];
        [array addObject:m];
    }
    dataBinding = [[MLNDataBinding alloc] init];
    model = [MLNTestModel new];
    model.source = array;
    model.source2d = @[array].mutableCopy;
    modelsArray = array;
    [dataBinding bindData:model forKey:@"userData"];
});

it(@"observer_chain", ^{
   MLNKVOObserver *ob = [[MLNKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        NSLog(@"%@",change);
   } keyPath:arrayKeyPath2];
   
   [dataBinding addMLNObserver:ob forKeyPath:arrayKeyPath2];
   [model.source2d[0] removeLastObject];
   [model.source2d removeLastObject];
   model.source2d = nil;
});

it(@"observer_once_remove", ^{
   NSString *bindKey = @"bindArr";
   NSMutableArray *arr = @[].mutableCopy;
   [dataBinding bindArray:arr forKey:bindKey];
   
   __block BOOL r1 = NO;
   __block BOOL r2 = NO;
   MLNKVOObserver *ob1 = [[MLNKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
    expect(r1).beFalsy();
    r1 = YES;
    expect(change[NSKeyValueChangeKindKey]).equal(@(NSKeyValueChangeInsertion));
   } keyPath:bindKey];
   
   MLNKVOObserver *ob2 = [[MLNKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
    expect(r2).beFalsy();
    r2 = YES;
    expect(change[NSKeyValueChangeKindKey]).equal(@(NSKeyValueChangeInsertion));
   } keyPath:bindKey];
   
   id ob1id = [dataBinding addMLNObserver:ob1 forKeyPath:bindKey];
   id ob2id = [dataBinding addMLNObserver:ob2 forKeyPath:bindKey];
   
   [arr addObject:@"abc"];
   expect(r1).beTruthy();
   expect(r2).beTruthy();
   r1 = NO;
   r2 = NO;
   [dataBinding removeMLNObserverByID:ob1id];
   [arr addObject:@"abc"];
   expect(r1).beFalsy();
   expect(r2).beTruthy();
});

it(@"setArray", ^{
   NSMutableArray *array = [NSMutableArray array];
   for(int i=0; i<2; i++) {
       MLNTestModel *m = [MLNTestModel new];
       m.open = i % 2;
       m.text = [NSString stringWithFormat:@"hello %d", i+10];
       [array addObject:m];
   }
   __block BOOL flag = NO;
   MLNKVOObserver *obs = [[MLNKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        NSString *key = [[arrayKeyPath componentsSeparatedByString:@"."] firstObject];
        NSString *path = [arrayKeyPath stringByReplacingOccurrencesOfString:[key stringByAppendingString:@"."] withString:@""];
        expect(keyPath).equal(arrayKeyPath);
//        expect(object).equal(model);
        id old = [change objectForKey:NSKeyValueChangeOldKey];
        id new = [change objectForKey:NSKeyValueChangeNewKey];
        expect(new).equal(array);
        expect(old).equal(modelsArray);
        expect(flag).beFalsy();
        flag = YES;
   } keyPath:arrayKeyPath];
   
   [dataBinding addMLNObserver:obs forKeyPath:arrayKeyPath];
   model.source = array;
   expect(flag).beTruthy();
});

SpecEnd
