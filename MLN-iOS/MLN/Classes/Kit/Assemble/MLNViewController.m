//
//  MLNViewController.m
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/10.
//

#import "MLNViewController.h"

@interface MLNViewController ()

@end

@implementation MLNViewController

#pragma mark - MLNViewControllerProtocol
- (MLNKitInstance *)kitInstance {
    return _luaInstance;
}

@end
