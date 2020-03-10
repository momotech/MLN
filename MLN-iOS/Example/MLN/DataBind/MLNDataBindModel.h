//
//  MLNDataBindModel.h
//  LuaNative
//
//  Created by Dai Dongpeng on 2020/3/10.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNDataBindModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;

@property (nonatomic, assign) BOOL open;
@property (nonatomic, copy) NSString *iconUrl;

+ (instancetype)testModel;

@end

NS_ASSUME_NONNULL_END
