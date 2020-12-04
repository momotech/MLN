//
//  ArgoBindingTest.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/25.
//

#if 1
//#import "ArgoBindingTest.h"
#import "ArgoObservableMap.h"
#import "ArgoObservableArray.h"
//#import "NSObject+ArgoListener.h"
//#import "NSObject+ArgoListener.h"
#import "ArgoUIKit.h"

@interface ArgoBindingTest : NSObject

@end

@implementation ArgoBindingTest

+ (void)load {
    static ArgoBindingTest *obj;
    obj = [ArgoBindingTest new];
//    [obj test];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [obj testString];
//    });
//    [obj testWatch];
//    [obj testArrayWatch];
//    [self testEncodeDecode];
    [self testNewWatch];
}

+ (void)testNewWatch {
    ArgoObservableMap *map = [ArgoObservableMap new];
    ArgoObservableMap *map1 = [ArgoObservableMap new];
    ArgoObservableMap *map11 = [ArgoObservableMap new];
    [map11 setObject:@"v1" forKey:@"k1"];
    [map1 setObject:map11 forKey:@"map11"];
    [map setObject:map1 forKey:@"map1"];
    
    map
    .watch(@"map1.map11.k1")
    .callback(^(id  _Nonnull oldValue, id  _Nonnull newValue, ArgoObservableMap * _Nonnull map) {
        NSLog(@">>>>> watch new is %@", newValue);
    });
    
    map.watchValue(@"map1.map11.k1")
    .callback(^(id  _Nonnull oldValue, id  _Nonnull newValue, ArgoObservableMap * _Nonnull map) {
        NSLog(@">>>>> watch value new is %@", newValue);
    });
    
    [map setObject:@"v2" forKey:@"map1"];
    [map performSelector:@selector(lua_putValue:forKey:) withObject:
     @{
         @"map11" : @{
                 @"k1" : @3333
         }.argo_mutableCopy
     }.argo_mutableCopy withObject:@"map1"];
}

+ (void)testEncodeDecode {
    ArgoObservableMap *map = [ArgoObservableMap new];
    [map setObject:@"aaa" forKey:@"kkk"];
    NSData *mapData = [NSKeyedArchiver archivedDataWithRootObject:map];
    ArgoObservableMap *r_map = [NSKeyedUnarchiver unarchiveObjectWithData:mapData];
    
    ArgoObservableArray *arr = [ArgoObservableArray new];
    [arr addObject:@"1111"];
    NSData *arrData = [NSKeyedArchiver archivedDataWithRootObject:arr];
    ArgoObservableMap *r_arr = [NSKeyedUnarchiver unarchiveObjectWithData:arrData];
    NSLog(@"%@ %@", r_map, r_arr);
}

- (void)testArrayWatch {
    ArgoObservableArray *array = [ArgoObservableArray new];
    
    ArgoWatchArrayWrapper *wrap = array
    .watch()
    .filter(^BOOL(ArgoWatchContext context, id  _Nonnull newValue) {
        return YES;
    })
    .callback(^(ArgoObservableArray * _Nonnull array, NSDictionary * _Nonnull change) {
        NSLog(@"");
    });

    [array addObject:@"aa"];
    array[1] = @"bb";
    [array replaceObjectAtIndex:0 withObject:@"change"];
    [wrap unwatch];
    
    [array addObject:@"cc"];
    [self testWatch];
}

- (void)testWatch {
    ArgoObservableMap *map = [ArgoObservableMap new];
    ArgoWatchWrapper *wrap = map
    .watch(@"list")
    .filter(kArgoFilter_Native)
    .callback(^(id  _Nonnull oldValue, id  _Nonnull newValue, ArgoObservableMap * _Nonnull map) {
        // ...
        NSLog(@"");
    });
    
    [map setObject:@"v1" forKey:@"k1"];
    [map setObject:@"v3" forKey:@"k3"];

    ArgoObservableArray *array = [ArgoObservableArray new];
    [map setObject:array forKey:@"list"];
    [map setObject:array forKey:@"list"];

    [array addObject:@"aa"];
    [wrap unwatch];
    [map setObject:array forKey:@"list"];

}

- (void)testString {
    int cnt = 5;
    {
        CFAbsoluteTime s = CFAbsoluteTimeGetCurrent();
        NSMutableString *str = [NSMutableString string];
        for (int i = 0; i < cnt; i++) {
            [str appendString:@(i).stringValue];
        }
        CFAbsoluteTime e = CFAbsoluteTimeGetCurrent();
        NSLog(@"mutalbe appendString cost %.2f ms", (e - s) * 1000);
    }
    
    {
        CFAbsoluteTime s = CFAbsoluteTimeGetCurrent();
        NSMutableString *str = [NSMutableString string];
        for (int i = 0; i < cnt; i++) {
            [str stringByAppendingFormat:@"%d",i];
        }
        CFAbsoluteTime e = CFAbsoluteTimeGetCurrent();
        NSLog(@"mutalbe appendStringFormat cost %.2f ms", (e - s) * 1000);
    }
    
    {
        CFAbsoluteTime s = CFAbsoluteTimeGetCurrent();
        NSString *str = @"";
        for (int i = 0; i < cnt; i++) {
            str = [str stringByAppendingString:@(i).stringValue];
        }
        CFAbsoluteTime e = CFAbsoluteTimeGetCurrent();
        NSLog(@"non-mutalbe appendString cost %.2f ms", (e - s) * 1000);
    }
}

/*
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
    
    ArgoObservableMap *map = [ArgoObservableMap new];
    ArgoObservableMap *map1 = [ArgoObservableMap new];
    ArgoObservableMap *map2 = [ArgoObservableMap new];
    ArgoObservableMap *map3 = [ArgoObservableMap new];

//    id<ArgoListenerToken> token = [map addArgoListenerWithChangeBlock:^(NSKeyValueChange type, id newValue, NSIndexSet *indexSet, NSDictionary *info) {
////        NSLog(@"type: %zd, new: %@, indexSet: %@, info: %@",type, newValue, indexSet, info);
//    } forKeyPath:@"userData.data.info.name"];
    
    id<ArgoListenerToken> token = [map addArgoListenerWithChangeBlock:^(NSString *keyPath, id<ArgoListenerProtocol> object, NSDictionary *change) {
        NSLog(@"object: %p keyPath: %@ change: %@",object,keyPath,change);
    } forKeyPath:@"userData.data.info.name" filter:nil];

    [map lua_putValue:map1 forKey:@"userData"]; // 1, null
    [map2 lua_putValue:map3 forKey:@"info"];
    [map3 lua_putValue:@"this is name" forKey:@"name"];
    [map1 lua_putValue:map2 forKey:@"data"];// 1, this is name
    
    [map3 lua_putValue:@"change" forKey:@"name"];// 1, change
    
    [map removeArgoListenerWithToken:token];
    
    [map2 lua_putValue:map3 forKey:@"info"];
    [map1 lua_putValue:map2 forKey:@"data"];
    [map lua_putValue:map1 forKey:@"userData"];
}

- (void)testArray {
    ArgoObservableMap *map = [ArgoObservableMap new];
    ArgoObservableMap *map1 = [ArgoObservableMap new];
    ArgoObservableArray *array = [ArgoObservableArray array];
    
    [map lua_putValue:map1 forKey:@"userData"];
    
    id<ArgoListenerToken> token = [map addArgoListenerWithChangeBlock:^(NSString *keyPath, id<ArgoListenerProtocol> object, NSDictionary *change) {
        NSLog(@"object: %p keyPath: %@ change: %@",object,keyPath,change);
    } forKeyPath:@"userData.list" filter:nil];
    
    [map1 lua_putValue:array forKey:@"list"];
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
    [map1 lua_putValue:array2 forKey:@"list"];
    [array2[2] addObject:@"abc"];
}
*/
@end

#endif
