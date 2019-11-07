//
//  MLNHomeDataHandler.m
//  MLN_Example
//
//  Created by Feng on 2019/11/7.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
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
