//
//  MLNGalleryMainViewController.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/5.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNGalleryMainViewController.h"
#import <SDWebImageDownloader.h>
#import "MLNGalleryHomeViewController.h"
#import "MLNGalleryDiscoverViewController.h"
#import "MLNGalleryPlusViewController.h"
#import "MLNGalleryMessageViewController.h"
#import "MLNGalleryMineViewController.h"
#import "UIImage+MLNResize.h"
#import <UIView+Toast.h>
#import "MLNLoadTimeStatistics.h"
#import <MLNDevTool/MLNFPSLabel.h>
#import "MLNGalleryNative.h"

@interface MLNGalleryMainViewController ()<UITabBarControllerDelegate>
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) MLNFPSLabel *fpsLabel;
@end

@implementation MLNGalleryMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupBackButton];
    [self setupTabbarItems];
}


- (void)setupBackButton
{
    [self backButton];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.fpsLabel = [[MLNFPSLabel alloc] initWithFrame:CGRectMake(10, screenHeight * 0.8, 50, 20)];
    [self.view addSubview:self.fpsLabel];
}

- (void)setupTabbarItems
{
    UIViewController *homeNavi = [self createControllerWithClass:@"MLNGalleryHomeViewController" normalImage:self.normalImage[0] selectedImage:self.selectedImage[0]];
    [self addChildViewController:homeNavi];
    
    UIViewController *discoverNav = [self createControllerWithClass:@"MLNGalleryDiscoverViewController" normalImage:self.normalImage[1] selectedImage:self.selectedImage[1]];
    [self addChildViewController:discoverNav];

    UIViewController *plusNavi = [self createControllerWithClass:@"MLNGalleryPlusViewController" normalImage:self.normalImage[2] selectedImage:self.selectedImage[2]];
    [self addChildViewController:plusNavi];

    UIViewController *messageNavi = [self createControllerWithClass:@"MLNGalleryMessageViewController" normalImage:self.normalImage[3] selectedImage:self.selectedImage[3]];
    [self addChildViewController:messageNavi];

    UIViewController *mineNavi = [self createControllerWithClass:@"MLNGalleryMineViewController" normalImage:self.normalImage[4] selectedImage:self.selectedImage[4]];
    [self addChildViewController:mineNavi];
}

- (UIViewController *)createControllerWithClass:(NSString *)clazzString normalImage:(NSString *)normalImageString selectedImage:(NSString *)selectedImageString
{
    UIViewController *controller = [NSClassFromString(clazzString) new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [navigationController setNavigationBarHidden:YES];
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:normalImageString] completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        UIImage *newImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
        navigationController.tabBarItem.image = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }];
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:selectedImageString] completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        UIImage *newImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
        navigationController.tabBarItem.selectedImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }];
    return navigationController;
}

#pragma mark - Action
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (viewController == [tabBarController.viewControllers objectAtIndex:2]) {
        [self.view makeToast:@"打开照相机📷" duration:1.0 position:CSToastPositionCenter];
        return NO;
    }
    
    [[MLNLoadTimeStatistics sharedInstance] recordStartTime];
    return YES;
}

- (void)backButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private method

- (NSArray *)normalImage {
    return @[@"https://s.momocdn.com/w/u/others/2019/08/27/1566877829621-hom.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877829567-disc.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877829827-plus.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877829551-msg.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877767583-min.png"];
}

- (NSArray *)selectedImage {
    return @[@"https://s.momocdn.com/w/u/others/2019/08/27/1566877829589-hom_d.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877829612-disc_d.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877829827-plus.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877829774-msg_d.png",
             @"https://s.momocdn.com/w/u/others/2019/08/27/1566877767564-min_d.png"];
}

- (UIButton *)backButton
{
    if (!_backButton) {
        CGFloat buttonW = 80;
        CGFloat buttonH = 30;
        CGFloat buttonX = kScreenWidth - buttonW - 10;
        CGFloat buttonY = 22;
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [_backButton setTitle:@"返回点我" forState:UIControlStateNormal];
        _backButton.backgroundColor = [UIColor orangeColor];
        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_backButton];
    }
    return _backButton;
}

@end
