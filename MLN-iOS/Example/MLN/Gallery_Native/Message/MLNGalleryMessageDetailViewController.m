//
//  MLNGalleryMessageDetailViewController.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/8.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNGalleryMessageDetailViewController.h"
#import "MLNGalleryNative.h"
#import "MLNGalleryNavigationBar.h"
#import "MLNGalleryNative.h"
#import "MLNLoadTimeStatistics.h"

@interface MLNGalleryMessageDetailViewController ()
@property (nonatomic, strong) MLNGalleryNavigationBar *navigationBar;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation MLNGalleryMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.navigationBar.frame = CGRectMake(0, 0, kScreenWidth, kNaviBarHeight);
    
    CGFloat contentLabelW = 100;
    CGFloat contentLabelH = 30;
    CGFloat contentLabelX = (kScreenWidth - contentLabelW)/2.0;
    CGFloat contentLabelY = (kScreenHeight - contentLabelH)/2.0;
    self.contentLabel.frame = CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH);
    
    [[MLNLoadTimeStatistics sharedInstance] recordEndTime];
    NSLog(@"<<<<<<<<<<<<<<<<<<原生消息二级页面私信布局完成：%@", @([[MLNLoadTimeStatistics sharedInstance]allLoadTime] * 1000));
}


- (MLNGalleryNavigationBar *)navigationBar
{
    if (!_navigationBar) {
        _navigationBar = [[MLNGalleryNavigationBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNaviBarHeight)];
        [self.navigationBar setTitle:self.titleString];
        MLNGalleryNavigationBarItem *leftItem = [[MLNGalleryNavigationBarItem alloc] init];
        leftItem.image = [UIImage imageNamed:@"icon_back"];
        [self.navigationBar setLeftItem:leftItem];
        __weak typeof(self) weakSelf = self;
        leftItem.clickActionBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        [self.view addSubview:_navigationBar];
    }
    return _navigationBar;
}

- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont boldSystemFontOfSize:14];
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.text = @"没有内容";
        [self.view addSubview:_contentLabel];
    }
    return _contentLabel;
}

@end
