//
//  MLNPackageManager.h
//  MMLNua_Example
//
//  Created by MOMO on 2019/11/2.
//  Copyright © 2019年 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MLNPackage;

typedef void (^MLNPackageLoadCompleteCallback)(BOOL, MLNPackage *, NSData *,NSString *);
NS_ASSUME_NONNULL_BEGIN

@interface MLNPackageManager : NSObject

+ (instancetype)sharedManager;

- (void)loadPackage:(MLNPackage *)package completion:(MLNPackageLoadCompleteCallback)completion;
- (void)loadPackage:(MLNPackage *)package needReload:(BOOL)needReload completion:(MLNPackageLoadCompleteCallback)completion;

@end

NS_ASSUME_NONNULL_END
