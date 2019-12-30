//
//  MLNMyHttpHandler.h
//  MLN_Example
//
//  Created by MoMo on 2019/9/2.
//  Copyright © 2019 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNMyHttpHandler : NSObject <MLNHttpHandlerProtocol>

- (void)http:(MLNHttp *)http get:(NSString *)urlString params:(NSDictionary *)params completionHandler:(void (^)(BOOL, NSDictionary *, NSDictionary *))completionHandler;
- (void)http:(MLNHttp *)http post:(NSString *)urlString params:(NSDictionary *)params completionHandler:(void (^)(BOOL, NSDictionary *, NSDictionary *))completionHandler;

@end

NS_ASSUME_NONNULL_END
