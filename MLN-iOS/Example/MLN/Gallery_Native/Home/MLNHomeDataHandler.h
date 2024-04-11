//
//  MLNHomeDataHandler.h
//  MLN_Example
//
//  Created by MoMo on 2019/11/7.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNHomeDataHandler : NSObject

@property (nonatomic, strong, readonly) NSArray *dataList1;
@property (nonatomic, strong, readonly) NSArray *dataList2;

+ (MLNHomeDataHandler *)handler;

- (void)updateDataList1:(NSArray *)dataList;
- (void)insertDataList1:(NSArray *)dataList;
- (void)updateDataList2:(NSArray *)dataList;
- (void)insertDataList2:(NSArray *)dataList;

@end

NS_ASSUME_NONNULL_END
