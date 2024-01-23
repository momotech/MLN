//
//  MLNLoadPipelineProtocol.h
//  MLN
//
//  Created by xue.yunqiang on 2022/2/23.
//

#import <Foundation/Foundation.h>
#import "MLNMonitorItem.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MLNLoadPipelineProtocol <NSObject>

- (void)willSetupMLNView;
- (void)findedResouce;
- (void)setupedLuaVM;
- (void)registedBridge;
- (void)fristRenderDone:(MLNMonitorItem *)item;

@end

NS_ASSUME_NONNULL_END
