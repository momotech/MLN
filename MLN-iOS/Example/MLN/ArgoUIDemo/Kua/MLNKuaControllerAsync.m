//
//  MLNKuaControllerAsync.m
//  LuaNative
//
//  Created by Dai on 2020/9/21.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNKuaControllerAsync.h"
#import "UserData.h"
#import "ArgoUIKit.h"
//#import "ArgoKuaViewModelUtils.h"

@interface MLNKuaControllerAsync ()
@property (nonatomic, strong) UserData *model;
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) CFTimeInterval didLoadTime;
@end

@implementation MLNKuaControllerAsync

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createController];
    self.didLoadTime = CFAbsoluteTimeGetCurrent();
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.startTime = CFAbsoluteTimeGetCurrent();
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.startTime > 0) {
        CFAbsoluteTime t1 = (self.didLoadTime - self.startTime) * 1000;
        CFAbsoluteTime t2 = (CFAbsoluteTimeGetCurrent() - self.didLoadTime) * 1000;
        NSLog(@">>>>>> lua-async didLoad %.2f ms, didAppear %.2f ms", t1, t2);
        self.startTime = 0;
    }
}

- (void)createController {
//    ArgoViewController *viewController = [[ArgoViewController alloc] initWithModelClass:UserData.class];
    ArgoViewController *viewController = [[ArgoViewController alloc] initWithEntryFileName:@"kuaDetail" bundleName:@"kuaDetailArgoUI"];
    self.model = [UserData defaultUserData];
    [viewController bindData:self.model];
    [viewController argo_addToSuperViewController:self frame:self.view.bounds];
}

@end
