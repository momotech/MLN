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
    id dataObject = @{@"ec":@(100),
                      @"em":@"success",
                      @"errcode":@(404),
                      @"data":@{},
                      @"list":@[]};
    
    MLNUIBenchMarkBegin
    MLNUITestModel *model = [MLNUITestModel new];
    model.errcode = 808;
    model.data = @{@"name":@"Tom", @"age":@(25), @"sex":@"man"}.mutableCopy;
    model.list = @[@"BB", @"CC", @"AA"].mutableCopy;
        
    const char *luaFunctionChunk = "return function(data, model, extra)\
    local viewModel = AutoWirePack(model) \
    viewModel.data.name = \"Alice\"\
    viewModel.list[1] = nil\
    local mm = AutoWireUnPack(viewModel) \
    return mm\
    end";
    
    
//    [[viewModel.em = \"okok\" \
//    [[viewModel.ec = 2020\
    
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
