//
//  MLNHomeDataHandler.h
//  MLN_Example
//
//  Created by Feng on 2019/11/7.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNHomeDataHandler : NSObject

@property (nonatomic, strong, readonly) NSArray *dataList;

+ (MLNHomeDataHandler *)handler;

- (void)updateDataList:(NSArray *)dataList;

@end

NS_ASSUME_NONNULL_END
