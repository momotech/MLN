//
//  MLNDictionaryTests.m
//  MLN_Tests
//
//  Created by Dai Dongpeng on 2020/3/11.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <NSDictionary+MLNKVO.h>

#define CreateDic(name,postfix) \
name = @{ \
    @"key_1" : @"value_1", \
    @"key_2" : @{ \
                @"key_2_1" : @{ \
                                @"key_2_1_1" : @{ \
                                                    @"name" : @"hello" \
                                                }.postfix \
                              }.postfix \
                }.postfix \
        }.postfix; \


SpecBegin(DictionaryTests)
__block NSDictionary *dic;
__block NSMutableDictionary *mutableDic;
beforeEach(^{
    CreateDic(dic, copy);
    CreateDic(mutableDic, mutableCopy);
});

#define CheckDic(cls) \
expect(map.count == 2).to.beTruthy(); \
expect(map).to.beKindOf([cls class]); \
expect(map[@"key_1"]).to.equal(@"value_1"); \
expect(map[@"key_2"]).to.beKindOf([cls class]); \
expect(map[@"key_2"][@"key_2_1"]).to.beKindOf([cls class]); \
expect(map[@"key_2"][@"key_2_1"][@"key_2_1_1"]).to.beKindOf([cls class]); \
expect(map[@"key_2"][@"key_2_1"][@"key_2_1_1"][@"name"]).to.equal(@"hello"); \

it(@"mln_mutableCopy", ^{
    NSMutableDictionary *map = dic.mln_mutalbeCopy;
    CheckDic(NSMutableDictionary);
});

it(@"mln_copy", ^{
    NSDictionary *map = mutableDic.mln_copy;
    CheckDic(NSDictionary);
});

SpecEnd

