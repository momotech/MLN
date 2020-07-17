//
//  MLNUIExtScope.m
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/4/9.
//

#import "MLNUIExtScope.h"
#import "MLNUIPerformanceHeader.h"

id <MLNUIPerformanceMonitor> MLNUIKitPerformanceMonitorForDebug;

void mlnui_executeCleanupBlock (__strong mlnui_cleanupBlock_t *block) {
    (*block)();
}
