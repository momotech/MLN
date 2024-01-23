//
//  MLNLuaViewInspectorBuilder.h
//  MLN
//
//  Created by xue.yunqiang on 2022/1/21.
//

#import <Foundation/Foundation.h>
#import "MLNInspector.h"
#import "MLNLuaViewErrorViewProtocol.h"
#import "MLNLuaViewLogUploadProtocol.h"
#import "MLNLoadPipelineProtocol.h"
#import "MLNListDetectItem.h"
#import "MLNDependenceProtocol.h"
#import "MLNKitInstanceDelegate.h"
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@protocol MLNLuaViewInspectorBuilderProtocol <NSObject>

@required
- (id<MLNLuaViewErrorViewProtocol>)errorViewInspector;
@optional
- (id<MLNDependenceProtocol>)dependenceHandle;
- (id<MLNKitInstanceDelegate>)instanceHandle;
- (NSArray<Class<MLNExportProtocol>> *)registerClasses;
- (id<MLNLoadPipelineProtocol>)pipelineHandle;
- (MLNListDetectItem *)detectItem;
- (NSArray<id<MLNInspector>> *)urlParselInspectors;
- (NSArray<id<MLNInspector>> *)resourceManageInspectors;
- (id<MLNLuaViewLogUploadProtocol>)logUploader;
- (id<MLNInspector,MLNKitInstanceErrorHandlerProtocol>)errorCacheInspectors;

@end

NS_ASSUME_NONNULL_END
