//
//  MLNHomeDataHandler.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/7.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNHomeDataHandler.h"

@interface MLNHomeDataHandler()
@property (nonatomic, strong, readwrite) NSArray *dataList;
@end

@implementation MLNHomeDataHandler

+ (MLNHomeDataHandler *)handler
{
    static MLNHomeDataHandler *_handler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _handler = [[MLNHomeDataHandler alloc] init];
    });
    return _handler;
}

- (void)updateDataList:(NSArray *)dataList
{
    _dataList = dataList;
}

@end
