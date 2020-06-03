//
//  JPFPSStatus.h
//  JPFPSStatus
//
//  Created by coderyi on 16/6/4.
//  Copyright © 2016年 http://coderyi.com . All rights reserved.
//  @ https://github.com/joggerplus/JPFPSStatus

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface JPFPSStatus : NSObject

@property (nonatomic,strong)UILabel *fpsLabel;

+ (JPFPSStatus *)sharedInstance;

- (void)open;
- (void)openWithHandler:(void (^)(NSInteger fpsValue))handler;
- (void)close;

@end
