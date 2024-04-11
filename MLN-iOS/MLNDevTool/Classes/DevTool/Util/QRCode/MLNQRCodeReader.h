//
//  MLNQRCode.h
//  Pods
//
//  Created by MoMo on 2019/9/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MLNQRCodeReaderCallback)(NSString * __nullable result, NSError *__nullable error);

@interface MLNQRCodeReader : NSObject

+ (instancetype)shareReader;

- (void)startWithView:(UIView *)view callback:(MLNQRCodeReaderCallback)callback;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
