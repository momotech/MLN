//
//  MLNKuaController.m
//  LuaNative
//
//  Created by Dongpeng Dai on 2020/8/11.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNKuaController.h"
//#import "MLNUIViewController.h"
#import "UserData.h"
#import "ArgoKit.h"
#import "ArgoKuaViewModelUtils.h"

@interface MLNKuaController ()
@property (nonatomic, strong) ArgoObservableMap *model;
@end

@implementation MLNKuaController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createController];
}

- (void)createController {
//    NSString *demoName = @"kuaDetail.lua";
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"KuaDemoMUI" ofType:@"bundle"];
//    NSBundle *bundle = [NSBundle bundleWithPath:path];
//    MLNUIViewController *viewController = [[MLNUIViewController alloc] initWithEntryFileName:demoName bundle:bundle];
//    ArgoViewController *viewController = [[ArgoViewController alloc] initWithEntryFileName:demoName bundleName:@"KuaDemoMUI"];
    ArgoViewController *viewController = [[ArgoViewController alloc] initWithModelClass:UserData.class];
//    self.model = [ArgoKuaViewModelUtils getKuaTestModel];
    self.model = [UserData defaultUserData];
    
//    self.model.mlnui_watch(@"name", ^(id  _Nonnull oldValue, id  _Nonnull newValue, id observedObject) {
//        NSLog(@"name has changed from  %@ to %@",oldValue, newValue);
//    });
//    self.model
//    .watch(@"name")
//    .callback(^(id  _Nonnull oldValue, id  _Nonnull newValue, ArgoObservableMap * _Nonnull map) {
//        NSLog(@"");
//    });
    
//    [viewController bindData:self.model forKey:@"userData"];
    [viewController bindData:self.model];
    [viewController mlnui_addToSuperViewController:self frame:self.view.bounds];
}

@end
