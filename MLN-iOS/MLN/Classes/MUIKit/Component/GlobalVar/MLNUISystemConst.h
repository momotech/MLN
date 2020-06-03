//
//  MLNUISystemConst.h
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/13.
//

#import <Foundation/Foundation.h>
#import "MLNUIGlobalVarExportProtocol.h"

typedef enum : NSUInteger {
    MLNUINetworkStatusUnknown = 0,
    MLNUINetworkStatusNoNetwork = 1,
    MLNUINetworkStatusWWAN = 2,
    MLNUINetworkStatusWifi = 3,
} MLNUINetworkStatus;

@interface MLNUISystemConst : NSObject <MLNUIGlobalVarExportProtocol>

@end
