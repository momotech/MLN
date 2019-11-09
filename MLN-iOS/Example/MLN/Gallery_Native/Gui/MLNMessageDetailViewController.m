//
//  MLNMessageDetailViewController.m
//  MLN_Example
//
//  Created by Feng on 2019/11/8.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import "MLNMessageDetailViewController.h"
#import "MLNGalleryNative.h"
#import "MLNGalleryNavigationBar.h"

@interface MLNMessageDetailViewController ()

@property (nonatomic, strong) MLNGalleryNavigationBar *navigationBar;

@end

@implementation MLNMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.navigationBar.frame = CGRectMake(0, 0, kScreenWidth, kNaviBarHeight);
    [self.navigationBar setTitle:self.title];
}


- (MLNGalleryNavigationBar *)navigationBar
{
    if (!_navigationBar) {
        _navigationBar = [[MLNGalleryNavigationBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNaviBarHeight)];
        MLNGalleryNavigationBarItem *leftItem = [[MLNGalleryNavigationBarItem alloc] init];
        leftItem.image = [UIImage imageNamed:@"1567316383505-minmore"];
        [self.navigationBar setLeftItem:leftItem];
        __weak typeof(self) weakSelf = self;
        leftItem.clickActionBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        
        MLNGalleryNavigationBarItem *rightItem = [[MLNGalleryNavigationBarItem alloc] init];
        rightItem.image = [UIImage imageNamed:@"1567316383469-minshare"];
        [self.navigationBar setRightItem:rightItem];
        rightItem.clickActionBlock = ^{
            NSLog(@"点击了分享按钮！！");
        };
        [self.view addSubview:_navigationBar];
    }
    return _navigationBar;
}

@end
