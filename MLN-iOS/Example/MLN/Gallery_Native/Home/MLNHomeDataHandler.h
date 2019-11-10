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

@property (nonatomic, strong, readonly) NSArray *dataList;

+ (MLNHomeDataHandler *)handler;

- (void)updateDataList:(NSArray *)dataList;
- (void)insertDataList:(NSArray *)dataList;

@end

NS_ASSUME_NONNULL_END
