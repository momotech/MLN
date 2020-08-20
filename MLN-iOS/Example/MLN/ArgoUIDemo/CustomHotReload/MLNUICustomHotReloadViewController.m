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

#define MLNUIBenchMarkBegin \
CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();

#define MLNUIBenchMarkEnd \
CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();\
printf("==>>ArgoUI time cost: %0.2fms\n", (end - begin) * 1000);

@interface MLNUICustomHotReloadViewController ()<MLNUILinkProtocol>

@property (nonatomic) dispatch_queue_t queue;

@end

@implementation MLNUICustomHotReloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testModelHandle];
}

#pragma mark - MLNUILinkProtocol

+ (UIViewController *)mlnLinkCreateController:(NSDictionary *)params closeCallback:(MLNUILinkCloseCallback)callback {
    NSString *fileName = [params objectForKey:@ENTRY_FILE_NAME];
    MLNUICustomHotReloadViewController *vc = [[MLNUICustomHotReloadViewController alloc] initWithEntryFileName:fileName];
    return vc;
}

#pragma mark - Test

- (void)testModelHandle {
    id dataObject = @{@"ec":@(100), @"em":@"success", @"data":@{}};
    
    MLNUIBenchMarkBegin
    MLNUITestModel *model = [MLNUITestModel new];
    const char *luaFunctionChunk = "return function(data, model, extra) model[\"em\"] = \"okok\" return model end";
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        MLNUITestModel *resultModel = [MLNUIModelHandler buildModelWithDataObject:dataObject model:model extra:nil functionChunk:luaFunctionChunk error:nil];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            MLNUIBenchMarkEnd
//            NSLog(@"==>>ArgoUI model is %@", resultModel);
//        });
//    });
    
//    MLNUITestModel *resultModel = [MLNUIModelHandler buildModelWithDataObject:dataObject model:model extra:nil functionChunk:luaFunctionChunk error:nil];
//    MLNUIBenchMarkEnd
//    NSLog(@"==>> model is %@", resultModel);
    
    [MLNUIModelHandler buildModelWithDataObject:dataObject model:model extra:nil functionChunk:luaFunctionChunk complete:^(__kindof NSObject *_Nonnull model, NSError *_Nonnull error) {
        MLNUIBenchMarkEnd
        NSLog(@"==>>ArgoUI model %@ , error: %@", model, error);
    }];
}

@end
