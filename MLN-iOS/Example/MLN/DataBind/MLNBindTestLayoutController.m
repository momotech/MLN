//
//  MLNBindTestLayoutController.m
//  LuaNative
//
//  Created by Dongpeng Dai on 2020/7/10.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNBindTestLayoutController.h"
#import "MLNUIKit.h"
#import "NSObject+MLNUIReflect.h"

@interface MLNBindTestLayoutController ()

@end

@implementation MLNBindTestLayoutController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *demoName = @"LayoutDemo.lua";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PerformanceDemoMUI" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    MLNUIViewController *viewController = [[MLNUIViewController alloc] initWithEntryFileName:demoName bundle:bundle];

    [self createModel:viewController];
    
//    [viewController bindData:self.tableModel forKey:@"goodsData"];
    [viewController mlnui_addToSuperViewController:self frame:self.view.bounds];
}

- (void)createModel:(MLNUIViewController *)con {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PerformanceDemoMUI" ofType:@"bundle"];
    path = [path stringByAppendingPathComponent:@"ViewModel"];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (NSString *file in files) {
        NSString *filePath = [path stringByAppendingPathComponent:file];
        NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        obj = [obj mlnui_convertToNativeObject];
        [con bindData:obj forKey:file];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
