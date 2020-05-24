//
//  MLNDBTestModel.h
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/5/22.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNDBTestItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int cnt;
+ (instancetype)testItem;
@end

@interface MLNDBTestModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) BOOL flag;

@property (nonatomic, strong) NSMutableDictionary <NSString *,MLNDBTestItem *>*map;
@property (nonatomic, strong) NSMutableArray <MLNDBTestItem *> *list;
@property (nonatomic, strong) NSMutableArray <NSMutableArray <MLNDBTestItem *> *> *list2;

+ (instancetype)testModel;
@end

NS_ASSUME_NONNULL_END
