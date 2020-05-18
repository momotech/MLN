//
//  MLNDefautImageloader.h
//  MLN
//
//  Created by Dai Dongpeng on 2020/5/13.
//

#import <Foundation/Foundation.h>
#import <MLNImageLoaderProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNDefautImageloader : NSObject <MLNImageLoaderProtocol>
+ (instancetype)defaultIamgeLoader;
@end

NS_ASSUME_NONNULL_END
