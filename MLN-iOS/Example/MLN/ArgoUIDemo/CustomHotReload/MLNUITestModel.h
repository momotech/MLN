//
//  MLNUITestModel.h
//  LuaNative
//
//  Created by xindong on 2020/8/18.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNUITestModel : NSObject

@property (nonatomic, assign) NSInteger ec;
@property (nonatomic, strong) NSString *em;
@property (nonatomic, assign) NSInteger errcode;
@property (nonatomic, strong) NSString *errmsg;
@property (nonatomic, assign) NSInteger timesec;
@property (nonatomic, strong) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
