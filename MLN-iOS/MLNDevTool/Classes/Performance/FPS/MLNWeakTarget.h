//
//  MLNWeakTarget.h
//  MLN_Example
//
//  Created by MoMo on 2019/11/2.
//  Copyright (c) 2019 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNWeakTarget : NSProxy

+ (instancetype)weakTargetWithObject:(NSObject *)object;

@end

NS_ASSUME_NONNULL_END
