//
//  FormatKeysTests.m
//  MLN_Tests
//
//  Created by Dai Dongpeng on 2020/5/23.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNDataBinding.h"

NSArray *formatKeys(NSArray *keys);

@interface FormatKeys : NSObject
- (NSDictionary *)getObserverinfo:(NSArray *)expect;
@end
@interface MLNDataBinding (FormatKeys)
-(NSArray *)formatKeys:(NSArray *)keys allowFirstKeyIsNumber:(BOOL)allowFirstKeyIsNumber allowLastKeyIsNumber:(BOOL)allowLastKeyIsNumber;
@end

SpecBegin(FormatKeys)

it(@"format", ^
   {
    NSArray *keys = @[
        @[@"a",@"b",@"c",@"d"],
        @[@"a",@"b",@1,@"c",@"d",@"e"],
        @[@2,@"a",@"b"],
        @[@"a",@"b",@"c",@3],
        @[@"a",@1,@2,@"c",@"d",@"e"],
        @[@"a",@1,@2,@"c",@"d",@"e",@1,@2],
        @[@"a",@"b",@1,@"c",@2,@3,@"d",@"e"],
        @[@"a"]
    ];
   
    NSArray *fKeys = @[
        @[@"a.b.c.d"],
        @[@"a.b",@1,@"c.d.e"],
        @[],
        @[],
        @[@"a",@1,@2,@"c.d.e"],
        @[],
        @[@"a.b",@1,@"c",@2,@3,@"d.e"],
        @[@"a"]
    ];
   
   NSArray *obs = @[
   @{@"object":@"map", @"keypath":@"a.b.c.d"},
   @{@"object":@"map.(a.b)[1]",@"keypath":@"c.d.e"},
   @{},
   @{},
   @{@"object":@"map.(a)[1][2]",@"keypath":@"c.d.e"},
   @{},
   @{@"object":@"map.(a.b)[1].(c)[2][3]",@"keypath":@"d.e"},
   @{@"object":@"map",@"keypath":@"a"}
   ];
   FormatKeys *fm = [FormatKeys new];
   MLNDataBinding *db = [MLNDataBinding new];
   
    for(int i = 0; i < keys.count; i++){
//   NSArray *format = [fm formatKeys:keys[i]];
   NSArray *format = [db formatKeys:keys[i] allowFirstKeyIsNumber:NO allowLastKeyIsNumber:NO];
   
    NSArray *expect = fKeys[i];
    if(expect.count == 0){
        expect(format).beNil();
        continue;
    }
    else{
        expect(format).equal(expect);
    }
    
   NSDictionary *dic = [fm getObserverinfo:expect];
   expect(dic).equal(obs[i]);
    NSLog(@">>>>> object %@   keyPath %@",dic[@"object"],dic[@"keypath"]);
}
});

SpecEnd


@implementation FormatKeys

- (NSDictionary *)getObserverinfo:(NSArray *)expect {
     NSString *object = @"map";
     NSString *keyPath = expect.firstObject;

     for(int i = 1; i < expect.count; i++) {
         NSString *k = expect[i];
         if([k isKindOfClass:[NSNumber class]]) {
            if(keyPath) {
             object = [object stringByAppendingFormat:@".(%@)",keyPath];
             keyPath = nil;
            }
             object = [object stringByAppendingFormat:@"[%@]",k];
         } else {
             keyPath = k;
         }
     }
    NSDictionary *dic = @{@"object":object,@"keypath":keyPath};
    return dic;
}
@end
