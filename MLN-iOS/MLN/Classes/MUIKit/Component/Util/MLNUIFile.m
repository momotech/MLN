//
//  MLNUIFile.m
//  
//
//  Created by MoMo on 2018/7/9.
//

#import "MLNUIFile.h"
#import "MLNUIKitHeader.h"
#import "MLNUIStaticExporterMacro.h"
#import "MLNUIBlock.h"
#import "MLNUIFileConst.h"
#import <CommonCrypto/CommonDigest.h>

#define kRelativeHeader @"file://"

static dispatch_queue_t file_operation_completion_queue() {
    static dispatch_queue_t mm_file_operation_completion_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mm_file_operation_completion_queue = dispatch_queue_create("com.wemomo.momokit.file.operation.queue", DISPATCH_QUEUE_SERIAL );
    });
    return mm_file_operation_completion_queue;
}

@implementation MLNUIFile

+ (BOOL)lua_fileExistAtPath:(NSString *)filePath
{
    if (!(filePath && filePath.length >0)) return NO;
    return [self existAtPath:filePath];
}

+ (BOOL)lua_isFile:(NSString *)filePath
{
    if (!(filePath && filePath.length >0)) return NO;
    BOOL isDirectory = NO;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[self realPath:filePath] isDirectory:&isDirectory];
    return !isDirectory && exist;
}

+ (BOOL)lua_isDirectory:(NSString *)filePath
{
    if (!(filePath && filePath.length >0)) return NO;
    BOOL isDirectory = NO;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[self realPath:filePath] isDirectory:&isDirectory];
    return isDirectory && exist;
}

+ (NSString*)lua_fileReadString:(NSString *)filePath
{
    NSData* data = nil;
    NSError* error = nil;
    int errCode = 0;
    if (filePath && filePath.length >0) {
        data = [NSData dataWithContentsOfFile:[self realPath:filePath] options:0 error:&error];
    }
    if (error) {
        errCode = MLNUIFileErrorCodeReadFailed;
    }
    NSString *ret = nil;
    if (errCode == 0 && data) {
        ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return ret;
}

+ (NSMutableDictionary *)lua_fileReadMap:(NSString *)filePath
{
    NSString* realPath = [self realPath:filePath];
    if ([self existAtPath:realPath]) {
        return [NSMutableDictionary dictionaryWithContentsOfFile:realPath];
    }
    return nil;
}

+ (NSMutableArray *)lua_fileReadArray:(NSString *)filePath
{
    NSString* realPath = [self realPath:filePath];
    if ([self existAtPath:realPath]) {
        return [NSMutableArray arrayWithContentsOfFile:realPath];
    }
    return nil;
}

+ (NSInteger)lua_fileWrite:(NSString *)filePath text:(NSString *)text
{
    NSString* realPath = [self realFilePath:filePath createDirIfNeed:YES];
    NSError* error;
    BOOL ret = [text writeToFile:realPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    int errCode = ret ? 0 : MLNUIFileErrorCodeWriteFailed;
    return errCode;
}

+ (NSInteger)lua_fileWrite:(NSString *)filePath map:(NSDictionary *)map
{
    BOOL ret = [map writeToFile:[self realFilePath:filePath createDirIfNeed:YES] atomically:YES];
    int errCode = ret ? 0 : MLNUIFileErrorCodeWriteFailed;
    return errCode;
}

+ (NSInteger)lua_fileWrite:(NSString *)filePath array:(NSArray *)array
{
    BOOL ret = [array writeToFile:[self realFilePath:filePath createDirIfNeed:YES] atomically:YES];
    int errCode = ret ? 0 : MLNUIFileErrorCodeWriteFailed;
    return errCode;
}

+ (NSInteger)lua_unzipFile:(NSString*)sourcePath targetPath:(NSString*)targetPath
{
    sourcePath = [self realFilePath:sourcePath createDirIfNeed:YES];
    int ret = MLNUIFileErrorCodeSourceFileNotExist;
    if ([self existAtPath:sourcePath]) {
//        NSURL *zipFileUrl = [NSURL fileURLWithPath:sourcePath];
        //        BOOL ret = [LVZipArchive unzipData:[NSData dataWithContentsOfURL:zipFileUrl] toDirectory:[self realDirectoryPath:targetPath createDirIfNeed:YES]];
        //        int errCode = ret ? 0 : MLNUIFileErrorCodeWriteFailed;
        //        return errCode;
    }
    return ret;
}

+ (void)lua_asyncUnzipFile:(NSString*)sourcePath targetPath:(NSString*)targetPath callback:(MLNUIBlock *)callback
{
    MLNUIStaticCheckTypeAndNilValue(callback, @"callback", MLNUIBlock);
    dispatch_async(file_operation_completion_queue(), ^{
        NSInteger ret = [self lua_unzipFile:sourcePath targetPath:targetPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                [callback addIntegerArgument:ret];
                [callback addStringArgument:sourcePath];
                [callback callIfCan];
            }
        });
    });
}

+ (void)lua_asyncWriteArray:(NSString*)targetPath array:(NSArray*)array callback:(MLNUIBlock*)callback
{
    NSString* realPath = [self realFilePath:targetPath createDirIfNeed:YES];
    if ([self lua_fileExistAtPath:realPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:realPath error:nil];
    }
    dispatch_async(file_operation_completion_queue(), ^{
        NSInteger ret = [self lua_fileWrite:targetPath array:array];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                [callback addIntegerArgument:ret];
                [callback addStringArgument:targetPath];
                [callback callIfCan];
            }
        });
    });
}

+ (void)lua_asyncWriteMap:(NSString*)targetPath map:(NSDictionary*)map callback:(MLNUIBlock*)callback {
    NSString* realPath = [self realFilePath:targetPath createDirIfNeed:YES];
    if ([self lua_fileExistAtPath:realPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:realPath error:nil];
    }
    dispatch_async(file_operation_completion_queue(), ^{
        NSInteger ret = [self lua_fileWrite:targetPath map:map];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                [callback addIntegerArgument:ret];
                [callback addStringArgument:targetPath];
                [callback callIfCan];
            }
        });
    });
}

+ (void)lua_asyncWriteFile:(NSString*)targetPath text:(NSString*)text callback:(MLNUIBlock*)callback {
    NSString* realPath = [self realFilePath:targetPath createDirIfNeed:YES];
    if ([self lua_fileExistAtPath:realPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:realPath error:nil];
    }
    dispatch_async(file_operation_completion_queue(), ^{
        NSInteger ret = [self lua_fileWrite:targetPath text:text];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                [callback addIntegerArgument:ret];
                [callback addStringArgument:targetPath];
                [callback callIfCan];
            }
        });
    });
}

+ (void)lua_asyncReadFile:(NSString*)sourcePath callback:(MLNUIBlock*)callback {
    dispatch_async(file_operation_completion_queue(), ^{
        NSString* ret = [self lua_fileReadString:sourcePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                int errCode = ret != nil ? 0 : MLNUIFileErrorCodeReadFailed;
                [callback addIntegerArgument:errCode];
                [callback addStringArgument:ret];
                [callback callIfCan];
            }
        });
    });
}

+ (void)lua_asyncReadMapFile:(NSString*)sourcePath callback:(MLNUIBlock*)callback {
    dispatch_async(file_operation_completion_queue(), ^{
        NSDictionary *ret = [self lua_fileReadMap:sourcePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                int errCode = ret != nil ? 0 : MLNUIFileErrorCodeReadFailed;
                [callback addIntegerArgument:errCode];
                if (ret) {
                   [callback addMapArgument:[NSMutableDictionary dictionaryWithDictionary:ret]];
                } else {
                    [callback addObjArgument:nil];
                }
                [callback callIfCan];
            }
        });
    });
}

+ (void)lua_asyncReadArrayFile:(NSString*)sourcePath callback:(MLNUIBlock*)callback {
    dispatch_async(file_operation_completion_queue(), ^{
        NSArray* ret = [self lua_fileReadArray:sourcePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                int errCode = ret != nil ? 0 : MLNUIFileErrorCodeReadFailed;
                [callback addIntegerArgument:errCode];
                if (ret) {
                    [callback addArrayArgument:[NSMutableArray arrayWithArray:ret]];
                } else {
                    [callback addObjArgument:nil];
                }
                [callback callIfCan];
            }
        });
    });
}

+ (NSString *)directoryWithPath:(NSString *)path {
    return [self realPath:path];
}

static NSString *fileManagerRootPath = nil;
+ (void)setFileManagerRootPath:(NSString *)rootPath
{
    fileManagerRootPath = rootPath;
}

+ (NSString *)fileManagerRootPath
{
    if (!fileManagerRootPath) {
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        fileManagerRootPath = [docDir stringByAppendingPathComponent:@"MLNUILua"];// 获取Documents目录路径
    }
    return fileManagerRootPath;
}

+ (NSString *)lua_getStorageDir
{
    return [self fileManagerRootPath];
}

+ (void)lua_asyncCreateFile:(NSString *)filePath completionBlock:(MLNUIBlock *)completion
{
    MLNUIKitLuaStaticAssert(filePath && filePath.length >0, @"The path of file creation must not be nil!");
    MLNUIStaticCheckTypeAndNilValue(completion, @"callback", MLNUIBlock);
    NSString *realFilePath = [self realFilePath:filePath createDirIfNeed:YES];
    if ([self existAtPath:realFilePath]) {
        if (completion) {
            [completion addIntArgument:MLNUIFileErrorCodeCreateFileFailed];
            [completion addStringArgument:filePath];
            [completion callIfCan];
        }
        return;
    }
    dispatch_async(file_operation_completion_queue(), ^{
        BOOL result = [[NSFileManager defaultManager] createFileAtPath:realFilePath contents:nil attributes:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                int errCode = result? 0 : MLNUIFileErrorCodeCreateFileFailed;
                [completion addIntArgument:errCode];
                [completion addStringArgument:filePath];
                [completion callIfCan];
            }
        });
    });
}

+ (void)lua_asyncCreateDirectory:(NSString *)directoryPath completionBlock:(MLNUIBlock *)completion
{
    MLNUIKitLuaStaticAssert(directoryPath && directoryPath.length >0, @"The path of directory creation must not be nil!");
    MLNUIStaticCheckTypeAndNilValue(completion, @"callback", MLNUIBlock);
    NSString *realDirectoryPath = [self realPath:directoryPath];
    if ([self existAtPath:realDirectoryPath]) {
        if (completion) {
            [completion addIntArgument:MLNUIFileErrorCodeCreateDirFailed];
            [completion addStringArgument:directoryPath];
            [completion callIfCan];
        }
        return;
    }
    dispatch_async(file_operation_completion_queue(), ^{
        NSError *error = nil;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:realDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                int errCode = result? 0 : MLNUIFileErrorCodeCreateDirFailed;
                [completion addIntArgument:errCode];
                [completion addStringArgument:directoryPath];
                [completion callIfCan];
            }
        });
    });
}

+ (void)lua_asyncDelete:(NSString *)path completionBlock:(MLNUIBlock *)completion
{
    MLNUIKitLuaStaticAssert(path && path.length >0, @"The path of deletion must not be nil!");
    MLNUIStaticCheckTypeAndNilValue(completion, @"callback", MLNUIBlock);
    NSString *realPath = [self realFilePath:path createDirIfNeed:YES];
    dispatch_async(file_operation_completion_queue(), ^{
        NSError *error = nil;
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:realPath error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                int errCode = result? 0 : MLNUIFileErrorCodeDeleteFileFailed;
                [completion addIntArgument:errCode];
                [completion addStringArgument:path];
                [completion callIfCan];
            }
        });
    });
}

+ (void)lua_asyncMoveFile:(NSString *)srcPath destPath:(NSString *)dstPath completionBlock:(MLNUIBlock *)completion
{
    MLNUIKitLuaStaticAssert(srcPath && srcPath.length >0, @"The source path of move must not be nil!");
    MLNUIKitLuaStaticAssert(dstPath && dstPath.length >0, @"The destination path of move must not be nil!");
    MLNUIStaticCheckTypeAndNilValue(completion, @"callback", MLNUIBlock);
    NSString *realSrcPath = [self realFilePath:srcPath createDirIfNeed:YES];
    NSString *realDstPath = [self realFilePath:dstPath createDirIfNeed:YES];
    dispatch_async(file_operation_completion_queue(), ^{
        NSError *error = nil;
        BOOL result = [[NSFileManager defaultManager] moveItemAtPath:realSrcPath toPath:realDstPath error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                int errCode = result? 0 : MLNUIFileErrorCodeMoveFileFailed;
                [completion addIntArgument:errCode];
                [completion addStringArgument:srcPath];
                [completion callIfCan];
            }
        });
    });
}

+ (void)lua_asyncCopyFile:(NSString *)srcPath destPath:(NSString *)dstPath completionBlock:(MLNUIBlock *)completion
{
    MLNUIKitLuaStaticAssert(srcPath && srcPath.length >0, @"The source path of move must not be nil!");
    MLNUIKitLuaStaticAssert(dstPath && dstPath.length >0, @"The destination path of move must not be nil!");
    MLNUIStaticCheckTypeAndNilValue(completion, @"callback", MLNUIBlock);
    NSString *realSrcPath = [self realFilePath:srcPath createDirIfNeed:YES];
    NSString *realDstPath = [self realFilePath:dstPath createDirIfNeed:YES];
    dispatch_async(file_operation_completion_queue(), ^{
        NSError *error = nil;
        BOOL result = [[NSFileManager defaultManager] copyItemAtPath:realSrcPath toPath:realDstPath error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                int errCode = result? 0 : MLNUIFileErrorCodeCopyFileFailed;
                [completion addIntArgument:errCode];
                [completion addStringArgument:srcPath];
                [completion callIfCan];
            }
        });
    });
}

+ (void)lua_getFileList:(NSString *)dstPath recursive:(BOOL)recursive completionBlock:(MLNUIBlock *)completion
{
    MLNUIKitLuaStaticAssert(dstPath && dstPath.length > 0, @"The path must not be nil!");
    MLNUIStaticCheckTypeAndNilValue(completion, @"callback", MLNUIBlock);
    if (!(dstPath && dstPath.length > 0)) {
        return;
    }
    NSString *realDirPath = [self realPath:dstPath];
    BOOL dirExist = [self existAtPath:realDirPath] && [self lua_isDirectory:realDirPath];
    MLNUIKitLuaStaticAssert(dirExist, @"The directory of %@ is not exist!", dstPath);
    if (!dirExist) {
        return;
    }
    dispatch_async(file_operation_completion_queue(), ^{
        NSError *error = nil;
        NSArray *array = nil;
        
        if (recursive) {
            array = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:realDirPath error:&error];
        } else {
            array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:realDirPath error:&error];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                int errCode = error? MLNUIFileErrorCodeGetFileListFailed : 0;
                [completion addIntArgument:errCode];
                [completion addArrayArgument:[NSMutableArray arrayWithArray:array]];
                [completion callIfCan];
            }
        });
    });
}

+ (NSMutableDictionary *)lua_getFileInfo:(NSString *)filePath
{
    BOOL isBlankPath = filePath && filePath.length > 0;
    MLNUIKitLuaStaticAssert(isBlankPath, @"The filePath must not be nil!");
    if (!isBlankPath) {
        return nil;
    }
    BOOL fileExist = [self existAtPath:filePath] && [self lua_isFile:filePath];
    MLNUIKitLuaStaticAssert(fileExist, @"The file is not exist!");
    if (!fileExist) {
        return nil;
    }
    NSString *realFilePath = [self realPath:filePath];
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:realFilePath error:&error];
    NSMutableDictionary *fileInfo = [NSMutableDictionary dictionary];
    [fileInfo setObject:@([fileAttributes fileSize]) forKey:kMLNUIFileSize];
    [fileInfo setObject:@([fileAttributes fileModificationDate].timeIntervalSince1970)forKey:kMLNUIModiDate];
    return fileInfo;
}

+ (void)lua_asyncReadFileMD5With:(NSString *)filePath completion:(MLNUIBlock *)completion
{
    MLNUIKitLuaStaticAssert(filePath && filePath.length > 0, @"The path must not be nil!");
    MLNUIStaticCheckTypeAndNilValue(completion, @"callback", MLNUIBlock);
    if (!(filePath && filePath.length > 0)) {
        return;
    }
    BOOL fileExist = [self existAtPath:filePath] && [self lua_isFile:filePath];
    MLNUIKitLuaStaticAssert(fileExist, @"The file is not exist!");
    if (!fileExist) {
        if (completion) {
            [completion addStringArgument:nil];
            [completion addIntArgument:MLNUIFileErrorCodeNotFile];
            [completion callIfCan];
        }
        return;
    }
    dispatch_async(file_operation_completion_queue(), ^{
        NSData *data = [NSData dataWithContentsOfFile:[self realPath:filePath]];
        NSString *md5 = nil;
        if(data){
            md5 = [self md5WithPath:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                int errCode = (md5 == nil)? (data ? MLNUIFileErrorCodeGetFileMD5ParseFailed : MLNUIFileErrorCodeNotFile) : 0;
                [completion addStringArgument:md5];
                [completion addIntArgument:errCode];
                [completion callIfCan];
            }
        });
    });
}

+ (NSString *)lua_syncReadFileMD5With:(NSString *)filePath
{
    MLNUIKitLuaStaticAssert(filePath && filePath.length > 0, @"The path must not be nil!");
    if (!(filePath && filePath.length > 0)) {
        return nil;
    }
    BOOL fileExist = [self existAtPath:filePath] && [self lua_isFile:filePath];
    MLNUIKitLuaStaticAssert(fileExist, @"The file is not exist!");
    if (!fileExist) {
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfFile:[self realPath:filePath]];
    NSString *md5 = nil;
    if(data){
        md5 = [self md5WithPath:data];
    }
    return md5;
}

+ (NSString *)lua_applicationRootPath
{
    return NSHomeDirectory();
}

#pragma mark - Private method

+ (BOOL)isRelativePath:(NSString *)filePath
{
    return [filePath hasPrefix:kRelativeHeader];
}

+ (BOOL)existAtPath:(NSString *)path
{
    NSString *realPath = [self realPath:path];
    return [[NSFileManager defaultManager] fileExistsAtPath:realPath];
}

+ (NSString *)realPath:(NSString *)path
{
    if ([self isRelativePath:path]) {
        NSString *temp = [path stringByReplacingOccurrencesOfString:kRelativeHeader withString:@""];
        NSString *rootPath =  fileManagerRootPath;
        return [rootPath stringByAppendingPathComponent:temp];
    }
    return path;
}

+ (NSString *)realFilePath:(NSString *)filePath createDirIfNeed:(BOOL)need
{
    if ([self isRelativePath:filePath]) {
        NSString *temp = [filePath stringByReplacingOccurrencesOfString:kRelativeHeader withString:@""];
        NSString *rootPath =  fileManagerRootPath;
        NSString *realFileDirPath = [[rootPath stringByAppendingPathComponent:temp] stringByDeletingLastPathComponent];
        if (![self existAtPath:realFileDirPath] && need) {
            [[NSFileManager defaultManager] createDirectoryAtPath:realFileDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        return [rootPath stringByAppendingPathComponent:temp];
    }
    return filePath;
}

+ (NSString*)realDirectoryPath:(NSString*)dirPath createDirIfNeed:(BOOL)need
{
    if ([self isRelativePath:dirPath]) {
        NSString *temp = [dirPath stringByReplacingOccurrencesOfString:kRelativeHeader withString:@""];
        NSString* rootPath = fileManagerRootPath;
        NSString* realDirPath = [rootPath stringByAppendingPathComponent:temp];
        if (![self existAtPath:realDirPath] && need) {
            [[NSFileManager defaultManager] createDirectoryAtPath:realDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        return realDirPath;
    }
    return dirPath;
}

#pragma mark - MD5
+ (NSString *)md5WithPath:(NSData *)data
{
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    CC_MD5_Update(&md5, [data bytes], (CC_LONG)data.length);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    
    NSString *md5Str = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", digest[0], digest[1], digest[2], digest[3], digest[4], digest[5], digest[6], digest[7], digest[8], digest[9], digest[10], digest[11], digest[12], digest[13], digest[14], digest[15]];
    
    return md5Str;
}

#pragma mark - Setup For Lua

LUA_EXPORT_STATIC_BEGIN(MLNUIFile)
LUA_EXPORT_STATIC_METHOD(exist, "lua_fileExistAtPath:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(isDir, "lua_isDirectory:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(isFile, "lua_isFile:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(syncReadArray, "lua_fileReadArray:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(syncReadMap, "lua_fileReadMap:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(syncReadString, "lua_fileReadString:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(syncWriteFile, "lua_fileWrite:text:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(syncWriteMap, "lua_fileWrite:map:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(syncWriteArray, "lua_fileWrite:array:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(syncUnzipFile, "lua_unzipFile:targetPath:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncUnzipFile, "lua_asyncUnzipFile:targetPath:callback:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncWriteArray, "lua_asyncWriteArray:array:callback:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncWriteMap, "lua_asyncWriteMap:map:callback:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncWriteFile, "lua_asyncWriteFile:text:callback:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncReadFile, "lua_asyncReadFile:callback:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncReadMapFile, "lua_asyncReadMapFile:callback:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncReadArrayFile, "lua_asyncReadArrayFile:callback:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(getStorageDir, "lua_getStorageDir", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncCreateFile, "lua_asyncCreateFile:completionBlock:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncCreateDirs, "lua_asyncCreateDirectory:completionBlock:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncDelete, "lua_asyncDelete:completionBlock:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncMoveFile, "lua_asyncMoveFile:destPath:completionBlock:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncCopyFile, "lua_asyncCopyFile:destPath:completionBlock:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncGetFileList, "lua_getFileList:recursive:completionBlock:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(getFileInfo, "lua_getFileInfo:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(asyncMd5File, "lua_asyncReadFileMD5With:completion:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(syncMd5File, "lua_syncReadFileMD5With:", MLNUIFile)
LUA_EXPORT_STATIC_METHOD(rootPath, "lua_applicationRootPath", MLNUIFile)
LUA_EXPORT_STATIC_END(MLNUIFile, File, NO, NULL)

@end
