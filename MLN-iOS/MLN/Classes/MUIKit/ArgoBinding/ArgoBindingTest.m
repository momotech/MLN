//
//  ArgoBindingTest.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/25.
//

#if 0
#import "ArgoBindingTest.h"
#import "ArgoObservableMap.h"
#import "ArgoObservableArray.h"

@interface ArgoBindingTest : NSObject

@end

@implementation ArgoBindingTest

+ (void)load {
    static ArgoBindingTest *obj;
    obj = [ArgoBindingTest new];
    [obj test];
}

- (void)test {
    [self testMap];
    [self testArray];
}

- (void)testMap {
    {
        int i1 = @"aa".intValue;
        int i2 = @"t19".intValue;
        int i3 = @"1mm".intValue;
        int i4 = @"a11".intValue;
        int i5 = @"0".intValue;
        NSLog(@"");
    }
    
    ArgoObservableMap *map = [ArgoObservableMap dictionaryWithCapacity:2];
    ArgoObservableMap *map1 = [ArgoObservableMap dictionaryWithCapacity:2];
    ArgoObservableMap *map2 = [ArgoObservableMap dictionaryWithCapacity:2];
    ArgoObservableMap *map3 = [ArgoObservableMap dictionaryWithCapacity:2];

//    id<ArgoListenerToken> token = [map addArgoListenerWithChangeBlock:^(NSKeyValueChange type, id newValue, NSIndexSet *indexSet, NSDictionary *info) {
////        NSLog(@"type: %zd, new: %@, indexSet: %@, info: %@",type, newValue, indexSet, info);
//    } forKeyPath:@"userData.data.info.name"];
    
    id<ArgoListenerToken> token = [map addArgoListenerWithChangeBlock:^(NSString *keyPath, id<ArgoListenerProtocol> object, NSDictionary *change) {
        NSLog(@"object: %p keyPath: %@ change: %@",object,keyPath,change);
    } forKeyPath:@"userData.data.info.name"];
    
    [map setObject:map1 forKey:@"userData"]; // 1, null
    
    [map2 setObject:map3 forKey:@"info"];
    [map3 setObject:@"this is name" forKey:@"name"];
    [map1 setObject:map2 forKey:@"data"];// 1, this is name
    
    [map3 setObject:@"change" forKey:@"name"];// 1, change
    
    [map removeArgoListenerWithToken:token];
    
    [map2 setObject:map3 forKey:@"info"];
    [map1 setObject:map2 forKey:@"data"];
    [map setObject:map1 forKey:@"userData"];
}

- (void)testArray {
    ArgoObservableMap *map = [ArgoObservableMap dictionaryWithCapacity:2];
    ArgoObservableMap *map1 = [ArgoObservableMap dictionaryWithCapacity:2];
    ArgoObservableArray *array = [ArgoObservableArray array];
    
    [map setObject:map1 forKey:@"userData"];
    
    id<ArgoListenerToken> token = [map addArgoListenerWithChangeBlock:^(NSString *keyPath, id<ArgoListenerProtocol> object, NSDictionary *change) {
        NSLog(@"object: %p keyPath: %@ change: %@",object,keyPath,change);
    } forKeyPath:@"userData.list"];
    
    [map1 setObject:array forKey:@"list"];
    [array addObject:@"1"];
    [array addObject:@"2"];
    [array removeObjectAtIndex:0];
    array[0] = @"33";
    
    //二维
    ArgoObservableArray *array2 = [ArgoObservableArray array];
    for (int i = 0; i < 10; i++) {
        ArgoObservableArray *arr = [ArgoObservableArray array];
        [array2 addObject:arr];
    }
    [map1 setObject:array2 forKey:@"list"];
    [array2[2] addObject:@"abc"];
}

@end

#endif
