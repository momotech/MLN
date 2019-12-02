//
//  MLNHomeDataHandler.m
//  MLN_Example
//
//  Created by MoMo on 2019/11/7.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import "MLNHomeDataHandler.h"

@interface MLNHomeDataHandler()
@property (nonatomic, strong, readwrite) NSMutableArray *dataList1;
@property (nonatomic, strong, readwrite) NSMutableArray *dataList2;
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

- (void)updateDataList1:(NSArray *)dataList
{
    _dataList1 = [dataList mutableCopy];
}

- (void)insertDataList1:(NSArray *)dataList
{
    [_dataList1 addObjectsFromArray:dataList];
}

- (void)updateDataList2:(NSArray *)dataList
{
    _dataList2 = [dataList mutableCopy];
}

- (void)insertDataList2:(NSArray *)dataList
{
    [_dataList2 addObjectsFromArray:dataList];
}


- (NSMutableArray *)dataList1
{
    if (!_dataList1) {
        _dataList1 = [[NSMutableArray alloc] init];
    }
    return _dataList1;
}

- (NSMutableArray *)dataList2
{
    if (!_dataList2) {
        _dataList2 = [[NSMutableArray alloc] init];
    }
    return _dataList2;
}

@end
