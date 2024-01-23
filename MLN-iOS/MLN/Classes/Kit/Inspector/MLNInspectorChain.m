//
//  MLNInspectorChain.m
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/4.
//

#import "MLNInspectorChain.h"
#import "MLNViewLoadModel.h"
#import "MLNInspector.h"
#import "MLNViewInspectorManager.h"
#import "MLNLuaViewDefaultURLParseInspector.h"
#import "MLNViewDefaultResourceManageInspector.h"
#import "MLNLuaWindowLayoutInspector.h"
#import "MLNLoadWindowInspector.h"
#import "MLNLuaViewDefaultErrorViewBuilder.h"
#import "MLNLuaViewDefualtErrorCatchInspector.h"
#import "MLNLuaViewLogUploadProtocol.h"
#import "MLNLuaViewDefaultLogUpload.h"

@interface MLNInspectorChain()

@property (nonatomic, strong) NSMutableArray<id <MLNInspector>>* inspectors;
@property (nonatomic, strong) NSArray<id<MLNInspector>> * urlParselInspectors;
@property (nonatomic, strong) NSArray<id<MLNInspector>> * resourceManageInspectors;

@property (nonatomic, strong) id <MLNInspector,MLNKitInstanceErrorHandlerProtocol> errorCatchInspector;
@property (nonatomic, strong) id<MLNLuaViewErrorViewProtocol> errorViewBuilder;
@property (nonatomic, strong) id<MLNLuaViewLogUploadProtocol> logUploader;

@end

@implementation MLNInspectorChain

- (void)addInspector:(id <MLNInspector>)inspector {
    if (inspector) {
        [self.inspectors addObject:inspector];
    }
}

- (void)addUrlParselInspectors:(NSArray<id<MLNInspector>> *)inspectors {
    _urlParselInspectors =  inspectors.count ? inspectors : self.urlParselInspectors;
}

- (void)addResourceManageInspectors:(NSArray<id<MLNInspector>> *)inspectors {
    _resourceManageInspectors = inspectors.count ? inspectors : self.resourceManageInspectors;
}

- (void)addLogUploader:(id <MLNLuaViewLogUploadProtocol>) logUploader {
    _logUploader = logUploader ? logUploader : self.logUploader;
}

- (void)addErrorCatchInspector:(id<MLNInspector,MLNKitInstanceErrorHandlerProtocol>)inspector {
    _errorCatchInspector = inspector ? inspector : self.errorCatchInspector;
}

- (void)addErrorViewBuilder:(id<MLNLuaViewErrorViewProtocol>)builder {
    _errorViewBuilder = builder ? builder : self.errorViewBuilder;
}

- (void)execute:(MLNViewLoadModel *)loadModel {
    [self addFinish];
    loadModel.errorViewBuilder = self.errorViewBuilder;
    loadModel.logUploader = self.logUploader;
    loadModel.errorCatchInspector = self.errorCatchInspector;
    for (id<MLNInspector> inspector in self.inspectors) {
        [inspector execute:loadModel];
        if (loadModel.stop) {
            break;
        }
        if (loadModel.error) {
            [self execute:loadModel];
            break;
        }
    }
}


- (void)addFinish {
    //assembel inspector
    if (!self.inspectors.count) {
        [self addInspector:self.errorCatchInspector];
        [self addInspector:[MLNLuaWindowLayoutInspector new]];
        for (id<MLNInspector> urlParsel in self.urlParselInspectors) {
            [self addInspector:urlParsel];
        }
        for (id<MLNInspector> resourceManage in self.resourceManageInspectors) {
            [self addInspector:resourceManage];
        }
        [self addInspector:[MLNLoadWindowInspector new]];
    }
}
#pragma mark - getter
-(NSMutableArray<id <MLNInspector>> *)inspectors {
    if (!_inspectors) {
        _inspectors = [[NSMutableArray alloc] init];
    }
    return _inspectors;
}

-(NSArray<id<MLNInspector>> *)urlParselInspectors {
    if (!_urlParselInspectors) {
        _urlParselInspectors = @[[MLNLuaViewDefaultURLParseInspector new]];
    }
    return _urlParselInspectors;
}

- (NSArray<id<MLNInspector>> *)resourceManageInspectors {
    if (!_resourceManageInspectors) {
        _resourceManageInspectors = @[[MLNViewDefaultResourceManageInspector new]];
    }
    return _resourceManageInspectors;
}

-(id<MLNInspector,MLNKitInstanceErrorHandlerProtocol>)errorCatchInspector {
    if (!_errorCatchInspector) {
        _errorCatchInspector = [MLNLuaViewDefualtErrorCatchInspector new];
    }
    return _errorCatchInspector;
}

-(id<MLNLuaViewErrorViewProtocol>)errorViewBuilder {
    if (!_errorViewBuilder) {
        _errorViewBuilder = [[MLNLuaViewDefaultErrorViewBuilder alloc] init];
    }
    return _errorViewBuilder;
}

-(id<MLNLuaViewLogUploadProtocol>)logUploader {
    if (!_logUploader) {
        _logUploader = [[MLNLuaViewDefaultLogUpload alloc] init];
    }
    return _logUploader;
}

@end
