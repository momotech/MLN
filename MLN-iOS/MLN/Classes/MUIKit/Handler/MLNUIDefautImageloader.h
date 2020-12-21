//
//  MLNUIDefautImageloader.h
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/5/13.
//

#import <Foundation/Foundation.h>
#import "MLNUIImageLoaderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIDefautImageloader : NSObject <MLNUIImageLoaderProtocol>
+ (instancetype)defaultIamgeLoader;
@end

NS_ASSUME_NONNULL_END
