//
//  MLNGalleryMineViewController.m
//  MLN_Example
//
//  Created by Feng on 2019/11/5.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNGalleryMineViewController.h"
#import "MLNGalleryNavigationBar.h"

@interface MLNGalleryMineViewController ()

@property (nonatomic, strong) MLNGalleryNavigationBar *navigationBar;

@end

@implementation MLNGalleryMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigation];
    
    // Do any additional setup after loading the view
}

- (void)setupNavigation
{
    [self.navigationBar setTitle:@"我的"];
    
    MLNGalleryNavigationBarItem *leftItem = [[MLNGalleryNavigationBarItem alloc] init];
    leftItem.image = [UIImage imageNamed:@"1567316383505-minmore"];
    [self.navigationBar setLeftItem:leftItem];
//    __weak typeof(self) weakSelf = self;
    leftItem.clickActionBlock = ^{
//        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"点击了更多按钮！！");
    };
    
    MLNGalleryNavigationBarItem *rightItem = [[MLNGalleryNavigationBarItem alloc] init];
    rightItem.image = [UIImage imageNamed:@"1567316383469-minshare"];
    [self.navigationBar setRightItem:rightItem];
    rightItem.clickActionBlock = ^{
        NSLog(@"点击了分享按钮！！");
    };
    
}


- (MLNGalleryNavigationBar *)navigationBar
{
    if (!_navigationBar) {
        _navigationBar = [[MLNGalleryNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kMLNNavigatorHeight)];
        [self.view addSubview:_navigationBar];
    }
    return _navigationBar;
}

@end
