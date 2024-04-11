//
//  MLNEncoderFActory.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import <UIKit/UIKit.h>
#import "LNEncoderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LNEncoderFactory : NSObject

+ (id<LNEncoderProtocol>)getEncoder;

@end

NS_ASSUME_NONNULL_END
