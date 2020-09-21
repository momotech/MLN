//
//  MLNKuaControllerAsync.m
//  LuaNative
//
//  Created by Dai on 2020/9/21.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNKuaControllerAsync.h"
#import "UserData.h"
#import "ArgoKit.h"
//#import "ArgoKuaViewModelUtils.h"

@interface MLNKuaControllerAsync ()
@property (nonatomic, strong) UserData *model;
@end

@implementation MLNKuaControllerAsync

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createController];
}

- (void)createController {
//    ArgoViewController *viewController = [[ArgoViewController alloc] initWithModelClass:UserData.class];
    ArgoViewController *viewController = [[ArgoViewController alloc] initWithEntryFileName:@"kuaDetail" bundleName:@"kuaDetailArgoUI"];
    self.model = [UserData defaultUserData];
    [viewController bindData:self.model];
    [viewController argo_addToSuperViewController:self frame:self.view.bounds];
}

@end
