//
//  MLNLoadWindowInspector.m
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/5.
//

#import "MLNLoadWindowInspector.h"
#import "MLNInspector.h"
#import "MLNViewLoadModel.h"
#import "MLNLuaView.h"
#import "MLNViewController.h"
#import "MLNLuaBundle.h"
#import "MLNKitInstance.h"
#import "MLNKitInstanceHandlersManager.h"
#import "MLNLuaViewInstanceHandle.h"

@interface MLNLoadWindowInspector()

@property(nonatomic, strong) MLNLuaViewInstanceHandle *instanceHandle;

@end

const char *MLNLoadWindowInspectorInstanceKey = "MLNLoadWindowInspectorInstanceKey";

@implementation MLNLoadWindowInspector

- (void)execute:(MLNViewLoadModel *)loadModel {
    if (loadModel.bundle.length || loadModel.fileFullPath.length) {
        MLNKitInstance *instance = [self creatKitInstance:loadModel];
        if (instance) {
            MLNLuaView *warpView = [MLNLuaView new];
            [warpView setInstance:instance];
            UIView *view = (id)instance.luaWindow;
            if (view) {
                [warpView sizeToFit];
                [warpView addSubview:view];
            }
            loadModel.luaView = warpView;
            [warpView setLoadModel:loadModel];
        }
    } else {
        loadModel.error = [[NSError alloc] initWithDomain:@"com.momo.mlnView" code:MLNLuaViewErrorFilePath userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"model bundle is nil, bundle need a path", nil)}];
    }
}

- (MLNKitInstance * _Nullable )creatKitInstance:(MLNViewLoadModel *)loadModel {
    MLNViewController *controller = [MLNViewController new];
    MLNKitInstance *instance = nil;
    instance = [[MLNKitInstance alloc] initWithLuaBundle:[MLNLuaBundle mainBundle] convertor:loadModel.convertorClass exporter:nil rootView:loadModel.rootView viewController:controller];
    [loadModel.pipelineHandle setupedLuaVM];
    instance.delegate = loadModel.instanceHandle ?: self.instanceHandle;
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:3];
    info[@"identfier"] = loadModel.identfier;
    info[@"version"] = loadModel.version;
    info[@"business"] = loadModel.business;
    instance.info = info;
    
    NSError *error = nil;
    if (loadModel.suppleLuaBridgeClasses.count) {
        [instance registerClasses:loadModel.suppleLuaBridgeClasses error:&error];
        if (error) {
            loadModel.error = [[NSError alloc] initWithDomain:@"com.momo.mlnView" code:MLNLuaViewErrorRegitClass userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(error.description, nil)}];
            return nil;
        }
    }
    [loadModel.pipelineHandle registedBridge];
    loadModel.detectItem.instance = instance;
    instance.detectItem = loadModel.detectItem;
    
    [instance changeLuaBundleWithPath: loadModel.fileFullPath.length ? loadModel.fileFullPath : loadModel.bundle];
    instance.instanceHandlersManager.errorHandler = loadModel.errorCatchInspector;
    controller.luaInstance = instance;
    [instance loadDependenceWithLuaBundleRootPath:loadModel.srcFilePath.length ? loadModel.srcFilePath : loadModel.bundle];
    BOOL success = [instance runWithEntryFile:loadModel.enterFilePath windowExtra:loadModel.windowExtro error:&error];
    if (!success) {
        NSMutableDictionary *failInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
        failInfo[NSLocalizedDescriptionKey] = NSLocalizedString(error.description, nil);
        failInfo[NSLocalizedFailureReasonErrorKey] = [instance.currentBundle bundlePath];
        loadModel.error = [[NSError alloc] initWithDomain:@"com.momo.mlnView" code:MLNLuaViewErrorLoadWindow userInfo:failInfo];
        return nil;
    }
    NSDictionary *moniterInfo = [loadModel basicInfo];
    MLNMonitorItem *item = [MLNMonitorItem new];
    [item setValuesForKeysWithDictionary:moniterInfo];
    [loadModel.pipelineHandle fristRenderDone:item];
    return instance;
}

-(MLNLuaViewInstanceHandle *)instanceHandle {
    if (!_instanceHandle) {
        _instanceHandle = [MLNLuaViewInstanceHandle new];
    }
    return _instanceHandle;
}

@end
