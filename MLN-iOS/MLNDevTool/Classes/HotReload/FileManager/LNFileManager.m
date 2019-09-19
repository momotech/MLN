//
//  MLNFileManager.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/11.
//

#import "LNFileManager.h"

@implementation LNFileManager {
    NSString *_luaBundlePath;
    NSString *_hotReloadBundlePath;
}

- (void)updateEntryFilePath:(NSString *)entryFilePath relativeFilePath:(NSString *)relativeFilePath
{
    _entryFilePath = [entryFilePath stringByReplacingOccurrencesOfString:@"file:///" withString:@""];
    _relativeEntryFilePath = relativeFilePath;
}

- (void)updateLuaBundlePath
{
    NSString *relativeBundlePath = [self.entryFilePath stringByDeletingLastPathComponent];
    _luaBundlePath = [_hotReloadBundlePath stringByAppendingPathComponent:relativeBundlePath];
}

- (BOOL)updateFile:(NSString *)filePath relativeFilePath:(NSString *)relativeFilePath data:(NSData *)data
{
    NSString *rawFilePath = filePath;
    rawFilePath = [rawFilePath stringByReplacingOccurrencesOfString:@"file:///" withString:@""];
    // 创建hot reload文件夹
    [self createHotReloadBundleIfNeed];
    // 创建单文件所在的文件夹
    NSString *dirPath = [rawFilePath stringByDeletingLastPathComponent];
    [self createDirectoryIfNeed:dirPath];
    // 获取完整路径
    NSString *fullPath = [self fullPath:rawFilePath];
    return [data writeToFile:fullPath atomically:YES];
}

- (BOOL)deleteFile:(NSString *)filePath
{
    filePath = [filePath stringByReplacingOccurrencesOfString:@"file:///" withString:@""];
    NSString *fullPath = [self fullPath:filePath];
    return [[NSFileManager defaultManager] removeItemAtPath:fullPath error:NULL];
}

- (BOOL)renameFile:(NSString *)filePath newFilePath:(NSString *)newFilePath
{
    return [self moveFile:filePath newFilePath:newFilePath];
}

- (BOOL)moveFile:(NSString *)filePath newFilePath:(NSString *)newFilePath
{
    filePath = [filePath stringByReplacingOccurrencesOfString:@"file:///" withString:@""];
    NSString *fullPath = [self fullPath:filePath];
    
    newFilePath = [newFilePath stringByReplacingOccurrencesOfString:@"file:///" withString:@""];
    NSString *newFullPath = [self fullPath:newFilePath];
    return [[NSFileManager defaultManager] moveItemAtPath:fullPath toPath:newFullPath error:NULL];
}

- (NSString *)fullPathWithRelativeFilePath:(NSString *)relativeFilePath
{
    return [self.luaBundlePath stringByAppendingPathComponent:relativeFilePath];
}

- (NSString *)fullPath:(NSString *)filePath
{
    return [self.hotReloadBundlePath stringByAppendingPathComponent:filePath];
}

#pragma mark - Create Bundle & Directory

- (void)createHotReloadBundleIfNeed
{
    [self createBundleIfNeed:self.hotReloadBundlePath];
}

- (void)createDirectoryIfNeed:(NSString *)relativeDirPath
{
    if (relativeDirPath && relativeDirPath.length >0) {
        NSString *dir = [self.hotReloadBundlePath stringByAppendingPathComponent:relativeDirPath];
        [self createBundleIfNeed:dir];
    }
}

- (void)createBundleIfNeed:(NSString *)bundlePath
{
    BOOL isDir = false;
    if (![[NSFileManager defaultManager] fileExistsAtPath:bundlePath isDirectory:&isDir] || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:bundlePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - Clear Bundle

- (void)clearLuaBundle
{
    [self createBundleIfNeed:self.luaBundlePath];
}

- (void)clearBundleIfNeed:(NSString *)bundlePath
{
    BOOL isDir = false;
    if (![[NSFileManager defaultManager] fileExistsAtPath:bundlePath isDirectory:&isDir] || !isDir) {
        [[NSFileManager defaultManager] removeItemAtPath:bundlePath error:nil];
    }
    [self createBundleIfNeed:bundlePath];
}

#pragma mark - Getter
- (NSString *)getRelativeEntryFilePath
{
    return [self.entryFilePath stringByDeletingPathExtension];
}

- (NSString *)hotReloadBundlePath {
    if (!_hotReloadBundlePath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _hotReloadBundlePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"/LuaHotReload"];
    }
    return _hotReloadBundlePath;
}

@end
