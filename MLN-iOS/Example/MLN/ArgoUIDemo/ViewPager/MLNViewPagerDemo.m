//
//  MLNViewPagerDemoViewController.m
//  LuaNative
//
//  Created by Dongpeng Dai on 2020/8/13.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNViewPagerDemo.h"
#import "MLNUIKit.h"
#import "HomeData.h"

@interface MLNViewPagerDemo ()
@property (nonatomic, strong) HomeData *model;
@end

@implementation MLNViewPagerDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createController];
}

- (void)createController {
    NSString *demoName = @"HomePage.lua";
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"ViewPagerDemoMUI" ofType:@"bundle"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"HomePageArgoUI" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    MLNUIViewController *viewController = [[MLNUIViewController alloc] initWithEntryFileName:demoName bundle:bundle];
    
    self.model = [HomeData defaultUserData];
    
    [viewController bindData:self.model forKey:@"homeData"];
    [viewController mlnui_addToSuperViewController:self frame:self.view.bounds];
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
