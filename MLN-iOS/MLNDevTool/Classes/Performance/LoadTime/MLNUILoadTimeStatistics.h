//
//  MLNUILoadTimeStatistics.h
//  MLNDevTool
//
//  Created by Dongpeng Dai on 2020/7/9.
//

#import <Foundation/Foundation.h>
#import <ArgoUI/MLNUIPerformanceHeader.h>

NS_ASSUME_NONNULL_BEGIN


@interface MLNUILoadTimeStatistics : NSObject <MLNUIPerformanceMonitor>

+ (instancetype)sharedStatistics;

@end

NS_ASSUME_NONNULL_END
