//
//  MLNBindTestCaseModel.h
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/5/13.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNBindTestCaseModel : NSObject
@property (nonatomic, copy) NSString *str;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) BOOL flag;
@property (nonatomic, assign) int num_i;
@property (nonatomic, assign) float num_f;

@property (nonatomic, assign) CGFloat num_cf;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, strong) NSValue *value_rect;
@property (nonatomic, strong) NSValue *value_point;
@property (nonatomic, strong) NSValue *value_size;

@property (nonatomic, copy) NSArray *array;
@property (nonatomic, strong) NSMutableArray *marray;
@property (nonatomic, copy) NSDictionary *dic;
@property (nonatomic, strong) NSMutableDictionary *mdic;

+ (instancetype)testModel;

@end

@interface MLNBindTestCaseModel2 : NSObject
//@property (nonatomic, assign) CGPoint point;
//@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSArray *tagArray;
@property (nonatomic, copy) NSString *info;

+ (instancetype)testModel;

@end

NS_ASSUME_NONNULL_END
