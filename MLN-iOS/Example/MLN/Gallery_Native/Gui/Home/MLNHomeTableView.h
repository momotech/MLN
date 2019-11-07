//
//  MLNHomeTableView.h
//  MLN_Example
//
//  Created by Feng on 2019/11/6.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNHomeTableView : UIView

@property (nonatomic, copy) NSString *tableType;

- (void)reloadTableWithDataList:(NSArray *)dataList;

@end

NS_ASSUME_NONNULL_END
