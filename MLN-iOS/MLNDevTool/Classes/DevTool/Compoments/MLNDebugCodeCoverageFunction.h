//
//  MLNDebugCodeCoverageFunction.h
//  MLNDevTool
//
//  Created by MOMO on 2019/12/24.
//

#import <Foundation/Foundation.h>
#import "MLNKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNDebugCodeCoverageFunction : NSObject<MLNGlobalFuncExportProtocol>

+ (void)updateLuaBundlePath:(NSString *)luaBundlePath;

@end

NS_ASSUME_NONNULL_END
