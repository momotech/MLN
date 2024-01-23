//
//  MLNViewResourceManageInspector.m
//  MLN
//
//  Created by xue.yunqiang on 2022/1/21.
//

#import "MLNViewDefaultResourceManageInspector.h"
#import "MLNInspector.h"
#import "MLNViewLoadModel.h"

@implementation MLNViewDefaultResourceManageInspector

- (void)execute:(MLNViewLoadModel *)loadModel {
    [self loadLuaViewPathWithLoadModel:loadModel];
    [loadModel.pipelineHandle findedResouce];
}

- (NSString *)findSandboxPath:(MLNViewLoadModel *)loadModel
{
    return nil;
}

- (BOOL)fileExistWithLoadModel:(MLNViewLoadModel *)loadModel
{
    BOOL exist = NO;
    
    // 1.sanbox
    NSString *sandboxPath = [self findSandboxPath:loadModel];
    if (sandboxPath.length) {
        loadModel.fileFullPath = sandboxPath;
        loadModel.bundle = nil;
        exist = YES;
    }
    
    // 2.bundle
    if (!exist) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:loadModel.identfier ofType:@"bundle"];
        if (bundlePath.length) {
            loadModel.fileFullPath = nil;
            loadModel.bundle = bundlePath;
            exist = YES;
        }
    }
    
    return exist;
}

- (void)loadLuaViewPathWithLoadModel:(MLNViewLoadModel *)loadModel
{
    if (![loadModel.identfier length] || ![loadModel.url64 length]) {
        return;
    }
    
    if (![self fileExistWithLoadModel:loadModel]) {
        // download
        [self downloadSource:loadModel];
    }
}

- (void)downloadSource:(MLNViewLoadModel *)loadModel
{
    NSURL *url = [NSURL URLWithString:loadModel.url64];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            // save to sandbox
        }
    }];
    [downloadTask resume];
}

@end
