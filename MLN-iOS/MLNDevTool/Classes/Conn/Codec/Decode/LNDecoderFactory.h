//
//  MLNDecoderFactory.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import <UIKit/UIKit.h>
#import "LNDecoderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNDecoderFactory : NSObject

+ (id<LNDecoderProtocol>)getDecoder;

@end

NS_ASSUME_NONNULL_END
