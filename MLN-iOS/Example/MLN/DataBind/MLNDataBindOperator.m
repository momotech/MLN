//
//  MLNDataBindOperator.m
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/5/22.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNDataBindOperator.h"
#import "MLNDBTestModel.h"

static MLNDataBindHotReload *_hotReload;
static MLNDataBindOperator *_currentOperator;

@interface MLNDataBindOperator()
@property (nonatomic, strong) MLNDBTestModel *normalModel;
@end

@implementation MLNDataBindOperator
- (instancetype)init
{
    self = [super init];
    if (self) {
        MLNDBTestModel *m = [MLNDBTestModel testModel];
        self.normalModel = m;
        [_hotReload.mln_dataBinding bindData:m forKey:@"userData"];
    }
    return self;
}

+ (void)setHotReload:(MLNDataBindHotReload *)hotReload {
    _hotReload = hotReload;
}

- (void)testNativeChange {
    MLNDBTestModel *m = self.normalModel;
    m.name = @"nt_name";
    m.number = @(2);
    m.color = [UIColor blueColor];
    m.height = 67;
    m.flag = YES;
}

- (void)testNativeArraySet {
    self.normalModel.list = self.normalModel.list;
    self.normalModel.list2 = self.normalModel.list2;
}

- (void)testNativeArrayAdd {
    MLNDBTestItem *item = [MLNDBTestItem testItem];
    [self.normalModel.list addObject:item];
    [self.normalModel.list2 addObject:@[item].mutableCopy];
}

- (void)testNativeArrayDelete {
    [self.normalModel.list removeLastObject];
    [self.normalModel.list2 removeLastObject];
}

- (void)testNativeArrayAdd2 {
    MLNDBTestItem *item = [MLNDBTestItem testItem];
    item.title = @"add2_title";
    [self.normalModel.list2.lastObject addObject:item];
}

- (void)testNativeArrayDelete2 {
    [self.normalModel.list2.lastObject removeLastObject];
}

LUA_EXPORT_BEGIN(MLNDataBindOperator)
LUA_EXPORT_METHOD(testNativeChange,"testNativeChange",MLNDataBindOperator)

LUA_EXPORT_METHOD(testNativeArraySet,"testNativeArraySet",MLNDataBindOperator)
LUA_EXPORT_METHOD(testNativeArrayAdd,"testNativeArrayAdd",MLNDataBindOperator)
LUA_EXPORT_METHOD(testNativeArrayDelete,"testNativeArrayDelete",MLNDataBindOperator)
LUA_EXPORT_METHOD(testNativeArrayAdd2,"testNativeArrayAdd2",MLNDataBindOperator)
LUA_EXPORT_METHOD(testNativeArrayDelete2,"testNativeArrayDelete2",MLNDataBindOperator)

LUA_EXPORT_END(MLNDataBindOperator,DBOP, NO, NULL, NULL)

@end
