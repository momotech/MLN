//
//  MLNLuaViewDefualtErrorCacheInspector.m
//  MLN
//
//  Created by xue.yunqiang on 2022/1/24.
//

#import "MLNLuaViewDefualtErrorCatchInspector.h"
#import "MLNInspector.h"
#import "MLNKitInstanceErrorHandlerProtocol.h"
#import "MLNViewLoadModel.h"
#import "MLNLuaViewErrorViewProtocol.h"
#import "MLNKitInstance.h"

@interface MLNLuaViewDefualtErrorCatchInspector()

@property (nonatomic, weak) MLNViewLoadModel *loadModel;

@property (nonatomic, strong) id<MLNLuaViewLogUploadProtocol> logUploader;

@end

@implementation MLNLuaViewDefualtErrorCatchInspector
#pragma mark - MLNInspector
- (void) execute:(MLNViewLoadModel *)loadModel {
    self.loadModel = loadModel;
    self.logUploader = loadModel.logUploader;
    if (loadModel.error) {
        //强制降级发生错误一定是预埋文件有问题 || bundle 路径存在代表在 bundle 加载,错误一定是预埋文件有问题
        if (loadModel.forceLocal || loadModel.bundle.length) {//预埋文件加载失败,显示加载失败视图
            loadModel.luaView = [loadModel.errorViewBuilder errorView:loadModel];
            NSMutableDictionary *logMDic = [NSMutableDictionary dictionary];
            logMDic[@"identfier"] = loadModel.identfier;
            logMDic[@"version"] = loadModel.version;
            logMDic[@"business"] = loadModel.business;
            logMDic[@"error"] = [NSString stringWithFormat:@"MLNLuaView:[error🔥]:显示默认加载失败视图 reason:%@",[loadModel.error description]];
            logMDic[@"errorType"] = @"lowest";
            logMDic[@"loadPath"] = loadModel.fileFullPath.length ? loadModel.fileFullPath : loadModel.bundle;
            logMDic[@"subPath"] = [self getSubpath:logMDic[@"loadPath"]];
            [loadModel.logUploader logUploadWithDic:logMDic];
            //trigger inspectors stop
            loadModel.stop = YES;
        } else {//命中降级策略
            NSMutableDictionary *logMDic = [NSMutableDictionary dictionary];
            logMDic[@"identfier"] = loadModel.identfier;
            logMDic[@"version"] = loadModel.version;
            logMDic[@"business"] = loadModel.business;
            logMDic[@"error"] = [NSString stringWithFormat:@"MLNLuaView:[error🔥]:错误处理: 降级 reason:%@",[loadModel.error description]];
            logMDic[@"errorType"] = @"degrade";
            logMDic[@"loadPath"] = loadModel.fileFullPath.length ? loadModel.fileFullPath : loadModel.bundle;
            [loadModel.logUploader logUploadWithDic:logMDic];
            loadModel.error = nil;
            loadModel.forceLocal = 1;
            [loadModel.loader loadView:loadModel];
        }
    }
}

-(NSString *)getSubpath:(NSString *)path {
    NSString *subStr = @"";
    if (!path.length) {
        return subStr;
    }
    NSError *subError = nil;
    NSArray *subArr = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:&subError];
    if (subArr.count) {
        for (NSString *path in subArr) {
            subStr = [subStr stringByAppendingFormat:@"%@,\n",path];
        }
    }
    if (subError) {
        subStr = [subStr stringByAppendingFormat:@"%@,\n",[subError description]];
    }
    return subStr;
}

#pragma mark - MLNKitInstanceErrorHandlerProtocol
- (BOOL)canHandleAssert:(MLNKitInstance *)instance {
    return YES;
}

- (void)instance:(MLNKitInstance *)instance error:(NSString *)error {
    
    NSMutableDictionary *logMDic = [NSMutableDictionary dictionaryWithDictionary:instance.info];
    logMDic[@"error"] = error;
    logMDic[@"errorType"] = @"lua runtime";
    [self uploadLog:logMDic];
}

- (void)instance:(MLNKitInstance *)instance luaError:(NSString *)error luaTraceback:(NSString *)luaTraceback {
    
    NSMutableDictionary *logMDic = [NSMutableDictionary dictionaryWithDictionary:instance.info];
    logMDic[@"error"] = error;
    logMDic[@"luaTraceback"] = luaTraceback;
    logMDic[@"errorType"] = @"lua runtime";
    [self uploadLog:logMDic];
}

- (void)uploadLog:(NSMutableDictionary *)params {
    NSDictionary *moniterInfo = [self.loadModel basicInfo];
    MLNMonitorItem *item = [MLNMonitorItem new];
    [item setValuesForKeysWithDictionary:moniterInfo];
    params[@"basicItem"] = item;
    [self.logUploader logUploadWithDic:params];
}

@end
