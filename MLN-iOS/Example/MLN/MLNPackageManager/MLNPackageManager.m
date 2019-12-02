//
//  MLNPackageManager.m
//  MMLNua_Example
//
//  Created by MOMO on 2019/11/2.
//  Copyright © 2019年 MOMO. All rights reserved.
//

#import "MLNPackageManager.h"
#import "MLNPackage.h"
#import "MLNMyHttpHandler.h"
#import "MLNZipArchive.h"

static dispatch_queue_t  mln_package_file_operation_completion_queue() {
    static dispatch_queue_t mln_in_package_file_operation_completion_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mln_in_package_file_operation_completion_queue = dispatch_queue_create("com.MLNPackage.file.operation.queue", DISPATCH_QUEUE_SERIAL );
    });
    return mln_in_package_file_operation_completion_queue;
}

@interface MLNPackageManager()

@property (nonatomic, strong) MLNHttp *http;
@property (nonatomic, strong) NSMutableDictionary *loadCompleteCallbacks;
@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation MLNPackageManager

+ (instancetype)sharedManager
{
    static MLNPackageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)loadPackage:(MLNPackage *)package completion:(MLNPackageLoadCompleteCallback)completion
{
    [self loadPackage:package needReload:NO completion:completion];
}

- (void)loadPackage:(MLNPackage *)package needReload:(BOOL)needReload completion:(MLNPackageLoadCompleteCallback)completion
{
    NSString *urlString = package.urlString;
    if (urlString == nil) {
        completion(false, package, nil, @"url string param is nil!");
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:urlString];
    if (!URL) {
        completion(false, package, nil, @"url string param is nil!");
        return;
    }
    
    if (package.bundlePath == nil) {
        completion(false, package, nil, @"bundlePath param is nil!");
        return;
    }
    
    NSString *resoucePath = [package.bundlePath stringByAppendingPathComponent:package.entryFile];
    
    //文件存在且不需要更新，返回成功
    if ([self.fileManager fileExistsAtPath:resoucePath] && !needReload) {
        NSData *data = [NSData dataWithContentsOfFile:resoucePath];
        if (completion) {
            completion(YES, package, data, @"下载成功！");
        }
        return;
    }
    
    
    [self.loadCompleteCallbacks setObject:completion forKey:package.urlString];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(package) weakPackage = package;
    NSString *tempPath = [NSString stringWithFormat:@"%@-temp", package.bundlePath];
    if ([self.fileManager fileExistsAtPath:tempPath]) {
        [self.fileManager removeItemAtPath:tempPath error:nil];
    }
    [self.fileManager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    __block NSURL *unzipURL = [NSURL fileURLWithPath:tempPath];
    __block NSURL *downloadURL  = [self getTempURLWith:unzipURL];
    __block NSURL *tempURL = [NSURL fileURLWithPath:tempPath];
    if (![self.fileManager fileExistsAtPath:downloadURL.path]) {
        [self.fileManager createDirectoryAtPath:downloadURL.path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [params setObject:downloadURL.path forKey:@"__path"];
    [self.http mln_download:urlString params:params progressHandler:^(float progress, float total) {
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        __weak typeof(weakPackage) strongPackage = weakPackage;
//
    } completionHandler:^(BOOL success, NSDictionary *respInfo, NSURL *filePath, NSDictionary *errorInfo) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        __strong typeof(weakPackage) strongPackage = weakPackage;
        MLNPackageLoadCompleteCallback callback = [strongSelf.loadCompleteCallbacks objectForKey:strongPackage.urlString];
        if (success) {
            [strongSelf unzipWithZipURL:filePath tempURL:tempURL package:strongPackage];
            [strongSelf.loadCompleteCallbacks removeObjectForKey:strongPackage.urlString];
        } else if(callback){
            callback(NO, strongPackage, nil ,errorInfo.description);
            [strongSelf.loadCompleteCallbacks removeObjectForKey:strongPackage.urlString];
        }
    }];
    
}

- (void)unzipWithZipURL:(NSURL *)zipURL tempURL:(NSURL *)tempURL package:(MLNPackage *)package
{
    NSFileManager *fileManager  = self.fileManager;
    MLNPackageLoadCompleteCallback callback = [self.loadCompleteCallbacks objectForKey:package.urlString];
    if (![fileManager fileExistsAtPath:zipURL.path] || zipURL == nil) {
        if (callback) {
            callback(NO, package, nil, @"下载失败，压缩包不存在！");
        }
        return;
    }
    
//    mln_package_file_operation_completion_queue
    BOOL ret = [MLNZipArchive unzipData:[NSData dataWithContentsOfURL:zipURL] toDirectory:tempURL.path];
    if (ret == NO) {
        [fileManager removeItemAtURL:tempURL error:nil];
        if (callback) {
            callback(NO, package, nil, @"解压失败");
        }
        return;
    }
    
    NSString *targetPath = package.bundlePath;
    NSURL *targetURL = [NSURL fileURLWithPath:targetPath];
    
    [fileManager removeItemAtURL:targetURL error:nil];
    
    NSError *error = nil;
    [fileManager moveItemAtURL:tempURL toURL:targetURL error:&error];
//    [fileManager copyItemAtURL:tempURL toURL:targetURL error:&error];
    
    if (!callback) {
        return;
    }
    if (!error) {
        NSString *resourcePath = [package.bundlePath stringByAppendingPathComponent:package.entryFile];
        if ([fileManager fileExistsAtPath:resourcePath]) {
            NSData *data = [NSData dataWithContentsOfFile:resourcePath];
            if (data) {
                callback(YES, package, data, @"下载成功！");
                return;
            }
        }
        callback(NO, package, nil, @"入口文件不存在");
    } else {
        callback(NO, package, nil, error.localizedDescription);
    }
}

- (NSString*)realDirectoryPath:(NSString*)dirPath createDirIfNeed:(BOOL)need
{
    BOOL isDirectory = YES;
    if ([self.fileManager fileExistsAtPath:dirPath isDirectory:&isDirectory]) {
        if (!isDirectory) {
            [self.fileManager removeItemAtPath:dirPath error:nil];
        }
    } else {
        [self.fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dirPath;
}

- (NSURL *)getTempURLWith:(NSURL *)loadURL;
{
    NSFileManager *manager = self.fileManager;
    NSURL *tempDir = [manager URLForDirectory:NSItemReplacementDirectory
                                     inDomain:NSUserDomainMask
                            appropriateForURL:loadURL
                                       create:YES
                                        error:nil];
    if (!tempDir) return nil;
    
    NSURL *tempURL = [tempDir URLByAppendingPathComponent:[loadURL lastPathComponent]];
    
    return tempURL;
}

#pragma mark - getter
- (MLNHttp *)http
{
    if (!_http) {
        _http = [[MLNHttp alloc] init];
    }
    return _http;
}

- (NSMutableDictionary *)loadCompleteCallbacks
{
    if (!_loadCompleteCallbacks) {
        _loadCompleteCallbacks = [NSMutableDictionary dictionary];
    }
    return _loadCompleteCallbacks;
}

- (NSFileManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [[NSFileManager alloc] init];
    }
    return _fileManager;
}


@end
