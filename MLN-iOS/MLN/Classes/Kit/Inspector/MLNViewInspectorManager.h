//
//  MLNViewInspectorManager.h
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/4.
//

#import <Foundation/Foundation.h>
@class MLNViewLoadModel,MLNInspectorChain;
@protocol MLNInspector,MLNKitInstanceErrorHandlerProtocol,MLNLuaViewErrorViewProtocol,MLNLuaViewLogUploadProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface MLNViewInspectorManager : NSObject

- (instancetype)initInspectorManager; NS_DESIGNATED_INITIALIZER;

- (void)addUrlParselInspectors:(NSArray<id<MLNInspector>> *)inspectors;

- (void)addResourceManageInspectors:(NSArray<id<MLNInspector>> *)inspectors;

- (void)addErrorCatchInspector:(id<MLNInspector,MLNKitInstanceErrorHandlerProtocol>)inspector;

- (void)addLogUploader:(id <MLNLuaViewLogUploadProtocol>) logUploader;

- (void)addErrorViewBuilder:(id<MLNLuaViewErrorViewProtocol>)builder;

- (void)inspectorLoad:(MLNViewLoadModel *) loadModel;

@end

NS_ASSUME_NONNULL_END
