//
//  MLNUICustomHotReloadViewController.m
//  LuaNative
//
//  Created by xindong on 2020/8/18.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNUICustomHotReloadViewController.h"
#import <MLNUILink.h>
#import <MLNUIModelHandler.h>
#import <MLNUIKitInstance.h>
#import <MLNHotReload.h>
#import "MLNUITestModel.h"

#define ENTRY_FILE_NAME "file"

#define MLNUIBenchMark(...) \
CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();\
__VA_ARGS__; \
CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();\
printf("==>>ArgoUI time cost: %0.2fms\n", (end - begin) * 1000);

@interface MLNUICustomHotReloadViewController ()<MLNUILinkProtocol>

@end

@implementation MLNUICustomHotReloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    __weak typeof(self) __unused weakSelf = self;
    [[MLNHotReload getInstance] setUpdateCallback:^(MLNKitInstance *_Nonnull instance) {
        [weakSelf testModelHandleWithLuaCore:(MLNUILuaCore *)instance.luaCore];
    }];
}

#pragma mark - MLNUILinkProtocol

+ (UIViewController *)mlnLinkCreateController:(NSDictionary *)params closeCallback:(MLNUILinkCloseCallback)callback {
    NSString *fileName = [params objectForKey:@ENTRY_FILE_NAME];
    MLNUICustomHotReloadViewController *vc = [[MLNUICustomHotReloadViewController alloc] initWithEntryFileName:fileName];
    return vc;
}

#pragma mark - Test

- (void)testModelHandleWithLuaCore:(MLNUILuaCore *)luaCore {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"xxx" ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    id dataObject =@{@"ec":@(100), @"em":@"success", @"data":@{}};
    MLNUIBenchMark(
                   MLNUITestModel *model = [MLNUITestModel new];
                   const char *luaFunctionChunk = "return function(data, model, extra) model[\"em\"] = \"okok\" return model end";
                   MLNUITestModel *resultModel = [MLNUIModelHandler buildModelWithDataObject:dataObject model:model extra:nil functionChunk:luaFunctionChunk];
                   );
    NSLog(@"model is %@", resultModel);
}

@end
