//
//  MLNArrayBindingTests.m
//  MLN_Tests
//
//  Created by Dai Dongpeng on 2020/3/5.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <MLNUIDataBinding.h>
#import <MLNUIKVOObserver.h>
#import "MLNTestModel.h"
#import <NSMutableArray+MLNUIKVO.h>

SpecBegin(ArrayBinding)

// fixed XCTest issue.
//[NSMutableArray load];

__block MLNUIDataBinding *dataBinding;
__block NSMutableArray *modelsArray;
NSString *arrayKeyPath = @"models";

beforeEach(^{
    modelsArray = [NSMutableArray array];
    for(int i=0; i<10; i++) {
        MLNTestModel *m = [MLNTestModel new];
        m.open = i % 2;
        m.text = [NSString stringWithFormat:@"hello %d", i+10];
        [modelsArray addObject:m];
    }
    dataBinding = [[MLNUIDataBinding alloc] init];
    [dataBinding bindArray:modelsArray forKey:arrayKeyPath];
});

it(@"observer", ^{
    __block BOOL result = NO;
    void(^observerBlock)(NSKeyValueChange,NSUInteger,NSUInteger,id,id) = ^(NSKeyValueChange type, NSUInteger index, NSUInteger expectedCount, id newValue, id oldValue){
        result = NO;
        MLNUIKVOObserver *obs = [[MLNUIKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
            NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
            expect(@(kind)).to.equal(@(type));
            
            NSArray *arr = (NSArray *)object;
            expect(arr).to.beKindOf([NSArray class]);
            
            NSIndexSet *set = [change objectForKey:NSKeyValueChangeIndexesKey];
            expect([set containsIndex:index]).to.beTruthy();
            
            id n = [change objectForKey:NSKeyValueChangeNewKey];
            expect((n==nil && newValue==nil) || ([n isEqual:newValue])).to.beTruthy();
            
            id o = [change objectForKey:NSKeyValueChangeOldKey];
            expect((o==nil && oldValue==nil) || ([o isEqual:oldValue])).to.beTruthy();

            expect(modelsArray.count == expectedCount).to.beTruthy();
            expect(result).to.beFalsy();
            result = YES;
        } keyPath:arrayKeyPath];
        
        [dataBinding addMLNUIObserver:obs forKeyPath:arrayKeyPath];
    };
    //five primitive methods
    it(@"addObject", ^{
        NSString *new = @"abc";
        observerBlock(NSKeyValueChangeInsertion, modelsArray.count, modelsArray.count + 1,new, nil);
        [modelsArray addObject:new];
        expect(result).to.beTruthy();
    });
    
    it(@"insertObject_atIndex", ^{
        NSString *new = @"def";
        observerBlock(NSKeyValueChangeInsertion, 0, modelsArray.count + 1, new, modelsArray[0]);
        [modelsArray insertObject:new atIndex:0];
        expect(result).to.beTruthy();
    });
    
    it(@"removeLastObject", ^{
        id old = modelsArray.lastObject;
        observerBlock(NSKeyValueChangeRemoval, modelsArray.count-1, modelsArray.count - 1, nil, old);
        [modelsArray removeLastObject];
        expect(result).to.beTruthy();
    });
    
    it(@"removeObjectAtIndex", ^{
        NSUInteger index = 5;
        id old = modelsArray[index];
        observerBlock(NSKeyValueChangeRemoval, index, modelsArray.count - 1, nil, old);
        [modelsArray removeObjectAtIndex:index];
        expect(result).to.beTruthy();
    });
    
    it(@"replaceObjectAtIndex_withObject", ^{
        NSUInteger index = 8;
        id old = modelsArray[index];
        id new = [MLNTestModel new];
        observerBlock(NSKeyValueChangeReplacement, index, modelsArray.count, new, old);
        [modelsArray replaceObjectAtIndex:index withObject:new];
        expect(result).to.beTruthy();
    });
    
    // other methods
    it(@"removeObject", ^{
        NSUInteger index = 3;
        id old = modelsArray[3];
        observerBlock(NSKeyValueChangeRemoval, index, modelsArray.count - 1, nil, old);
        [modelsArray removeObject:old];
        expect(result).to.beTruthy();
    });
    // NSExtendedMutableArray
    /*
     - (void)addObjectsFromArray:(NSArray<ObjectType> *)otherArray;
     - (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
     - (void)removeAllObjects;
     - (void)removeObject:(ObjectType)anObject inRange:(NSRange)range;
     - (void)removeObject:(ObjectType)anObject;
     - (void)removeObjectIdenticalTo:(ObjectType)anObject inRange:(NSRange)range;
     - (void)removeObjectIdenticalTo:(ObjectType)anObject;
     - (void)removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)cnt API_DEPRECATED("Not supported", macos(10.0,10.6), ios(2.0,4.0), watchos(2.0,2.0), tvos(9.0,9.0));
     - (void)removeObjectsInArray:(NSArray<ObjectType> *)otherArray;
     - (void)removeObjectsInRange:(NSRange)range;
     - (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ObjectType> *)otherArray range:(NSRange)otherRange;
     - (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ObjectType> *)otherArray;
     - (void)setArray:(NSArray<ObjectType> *)otherArray;
     - (void)sortUsingFunction:(NSInteger (NS_NOESCAPE *)(ObjectType,  ObjectType, void * _Nullable))compare context:(nullable void *)context;
     - (void)sortUsingSelector:(SEL)comparator;
     
     - (void)insertObjects:(NSArray<ObjectType> *)objects atIndexes:(NSIndexSet *)indexes;
     - (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
     - (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray<ObjectType> *)objects;
     
     - (void)setObject:(ObjectType)obj atIndexedSubscript:(NSUInteger)idx API_AVAILABLE(macos(10.8), ios(6.0), watchos(2.0), tvos(9.0));
     */
    
    afterEach(^{
        NSLog(@"%@",modelsArray);
    });
});

it(@"observer_once", ^{
   NSMutableArray *arr = @[].mutableCopy;
   [dataBinding bindArray:arr forKey:@"arr"];
   
   __block BOOL r1 = NO;
   __block BOOL r2 = NO;
   MLNUIKVOObserver *ob1 = [[MLNUIKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
    expect(r1).beFalsy();
    r1 = YES;
    expect(change[NSKeyValueChangeKindKey]).equal(@(NSKeyValueChangeInsertion));
   } keyPath:nil];
   
   MLNUIKVOObserver *ob2 = [[MLNUIKVOObserver alloc] initWithViewController:nil callback:^(NSString * _Nonnull keyPath, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
    expect(r2).beFalsy();
    r2 = YES;
    expect(change[NSKeyValueChangeKindKey]).equal(@(NSKeyValueChangeInsertion));
   } keyPath:nil];
   
   [dataBinding addMLNUIObserver:ob1 forKeyPath:@"arr"];
   [dataBinding addMLNUIObserver:ob2 forKeyPath:@"arr"];
   
   [arr addObject:@"abc"];
   expect(r1).beTruthy();
   expect(r2).beTruthy();
});

SpecEnd
