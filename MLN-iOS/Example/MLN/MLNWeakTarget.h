//
//  MLNWeakTarget.h
//  MLN_Example
//
//  Created by Feng on 2019/11/2.
//  Copyright © 2019 liu.xu_1586. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNWeakTarget : NSProxy

+ (instancetype)weakTargetWithObject:(NSObject *)object;

@end

NS_ASSUME_NONNULL_END
