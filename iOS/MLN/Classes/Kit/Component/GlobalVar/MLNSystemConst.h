//
//  MLNSystemConst.h
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import <Foundation/Foundation.h>
#import "MLNGlobalVarExportProtocol.h"

typedef enum : NSUInteger {
    MLNNetworkStatusUnknown = 0,
    MLNNetworkStatusNoNetwork = 1,
    MLNNetworkStatusWWAN = 2,
    MLNNetworkStatusWifi = 3,
} MLNNetworkStatus;

@interface MLNSystemConst : NSObject <MLNGlobalVarExportProtocol>

@end
