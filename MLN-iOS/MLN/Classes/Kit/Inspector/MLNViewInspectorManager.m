//
//  MLNViewInspectorManager.m
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/4.
//

#import "MLNViewInspectorManager.h"
#import "MLNInspectorChain.h"
#import "MLNInspector.h"
#import "MLNLuaViewLogUploadProtocol.h"

@interface MLNViewInspectorManager()

@property (nonatomic, strong) MLNInspectorChain * inspectorChain;

@end

@implementation MLNViewInspectorManager

- (instancetype)initInspectorManager {
    if (self = [super init]) {
        self.inspectorChain = [MLNInspectorChain new];
    }
    return self;
}

- (void)addUrlParselInspectors:(NSArray<id<MLNInspector>> *)inspectors {
    NSAssert(_inspectorChain != nil, @"_filterChain can't be nil");
    [_inspectorChain addUrlParselInspectors:inspectors];
}

- (void)addResourceManageInspectors:(NSArray<id<MLNInspector>> *)inspectors {
    NSAssert(_inspectorChain != nil, @"_filterChain can't be nil");
    [_inspectorChain addResourceManageInspectors:inspectors];
}

- (void)addErrorCatchInspector:(id<MLNInspector,MLNKitInstanceErrorHandlerProtocol>)inspector {
    NSAssert(_inspectorChain != nil, @"_filterChain can't be nil");
    [_inspectorChain addErrorCatchInspector:inspector];
}

- (void)addErrorViewBuilder:(id<MLNLuaViewErrorViewProtocol>)builder {
    NSAssert(_inspectorChain != nil, @"_filterChain can't be nil");
    [_inspectorChain addErrorViewBuilder:builder];
}

- (void)addLogUploader:(id <MLNLuaViewLogUploadProtocol>) logUploader {
    NSAssert(_inspectorChain != nil, @"_filterChain can't be nil");
    [_inspectorChain addLogUploader:logUploader];
}

- (void)inspectorLoad:(MLNViewLoadModel *) loadModel {
    [_inspectorChain execute:loadModel];
}
@end
