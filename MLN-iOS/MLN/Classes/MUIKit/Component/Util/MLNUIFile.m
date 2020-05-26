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

+ (BOOL)luaui_fileExistAtPath:(NSString *)filePath
{
    if (!(filePath && filePath.length >0)) return NO;
    return [self existAtPath:filePath];
}

+ (BOOL)luaui_isFile:(NSString *)filePath
{
    if (!(filePath && filePath.length >0)) return NO;
    BOOL isDirectory = NO;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[self realPath:filePath] isDirectory:&isDirectory];
    return !isDirectory && exist;
}

+ (BOOL)luaui_isDirectory:(NSString *)filePath
{
    if (!(filePath && filePath.length >0)) return NO;
    BOOL isDirectory = NO;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[self realPath:filePath] isDirectory:&isDirectory];
    return isDirectory && exist;
}

+ (NSString*)luaui_fileReadString:(NSString *)filePath
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

+ (NSMutableDictionary *)luaui_fileReadMap:(NSString *)filePath
{
    NSString* realPath = [self realPath:filePath];
    if ([self existAtPath:realPath]) {
        return [NSMutableDictionary dictionaryWithContentsOfFile:realPath];
    }
    return nil;
}

+ (NSMutableArray *)luaui_fileReadArray:(NSString *)filePath
{
    NSString* realPath = [self realPath:filePath];
    if ([self existAtPath:realPath]) {
        return [NSMutableArray arrayWithContentsOfFile:realPath];
    }
    return nil;
}

+ (NSInteger)luaui_fileWrite:(NSString *)filePath text:(NSString *)text
{
    NSString* realPath = [self realFilePath:filePath createDirIfNeed:YES];
    NSError* error;
    BOOL ret = [text writeToFile:realPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    int errCode = ret ? 0 : MLNUIFileErrorCodeWriteFailed;
    return errCode;
}

+ (NSInteger)luaui_fileWrite:(NSString *)filePath map:(NSDictionary *)map
{
    BOOL ret = [map writeToFile:[self realFilePath:filePath createDirIfNeed:YES] atomically:YES];
    int errCode = ret ? 0 : MLNUIFileErrorCodeWriteFailed;
    return errCode;
}

+ (NSInteger)luaui_fileWrite:(NSString *)filePath array:(NSArray *)array
{
    BOOL ret = [array writeToFile:[self realFilePath:filePath createDirIfNeed:YES] atomically:YES];
    int errCode = ret ? 0 : MLNUIFileErrorCodeWriteFailed;
    return errCode;
}

+ (NSInteger)luaui_unzipFile:(NSString*)sourcePath targetPath:(NSString*)targetPath
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

+ (void)luaui_asyncUnzipFile:(NSString*)sourcePath targetPath:(NSString*)targetPath callback:(MLNUIBlock *)callback
{
    MLNUIStaticCheckTypeAndNilValue(callback, @"callback", MLNUIBlock);
    dispatch_async(file_operation_completion_queue(), ^{
        NSInteger ret = [self luaui_unzipFile:sourcePath targetPath:targetPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                [callback addIntegerArgument:ret];
                [callback addStringArgument:sourcePath];
                [callback callIfCan];
            }
        });
    });
}

+ (void)luaui_asyncWriteArray:(NSString*)targetPath array:(NSArray*)array callback:(MLNUIBlock*)callback
{
    NSString* realPath = [self realFilePath:targetPath createDirIfNeed:YES];
    if ([self luaui_fileExistAtPath:realPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:realPath error:nil];
    }
    dispatch_async(file_operation_completion_queue(), ^{
        NSInteger ret = [self luaui_fileWrite:targetPath array:array];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                [callback addIntegerArgument:ret];
                [callback addStringArgument:targetPath];
                [callback callIfCan];
            }
        });
    });
}

+ (void)luaui_asyncWriteMap:(NSString*)targetPath map:(NSDictionary*)map callback:(MLNUIBlock*)callback {
    NSString* realPath = [self realFilePath:targetPath createDirIfNeed:YES];
    if ([self luaui_fileExistAtPath:realPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:realPath error:nil];
    }
    dispatch_async(file_operation_completion_queue(), ^{
        NSInteger ret = [self luaui_fileWrite:targetPath map:map];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                [callback addIntegerArgument:ret];
                [callback addStringArgument:targetPath];
                [callback callIfCan];
            }
        });
    });
}

+ (void)luaui_asyncWriteFile:(NSString*)targetPath text:(NSString*)text callback:(MLNUIBlock*)callback {
    NSString* realPath = [self realFilePath:targetPath createDirIfNeed:YES];
    if ([self luaui_fileExistAtPath:realPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:realPath error:nil];
    }
    dispatch_async(file_operation_completion_queue(), ^{
        NSInteger ret = [self luaui_fileWrite:targetPath text:text];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                [callback addIntegerArgument:ret];
                [callback addStringArgument:targetPath];
                [callback callIfCan];
            }
        });
    });
}

+ (void)luaui_asyncReadFile:(NSString*)sourcePath callback:(MLNUIBlock*)callback {
    dispatch_async(file_operation_completion_queue(), ^{
        NSString* ret = [self luaui_fileReadString:sourcePath];
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

+ (void)luaui_asyncReadMapFile:(NSString*)sourcePath callback:(MLNUIBlock*)callback {
    dispatch_async(file_operation_completion_queue(), ^{
        NSDictionary *ret = [self luaui_fileReadMap:sourcePath];
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

+ (void)luaui_asyncReadArrayFile:(NSString*)sourcePath callback:(MLNUIBlock*)callback {
    dispatch_async(file_operation_completion_queue(), ^{
        NSArray* ret = [self luaui_fileReadArray:sourcePath];
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

+ (NSString *)luaui_getStorageDir
{
    return [self fileManagerRootPath];
}

+ (void)luaui_asyncCreateFile:(NSString *)filePath completionBlock:(MLNUIBlock *)completion
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

+ (void)luaui_asyncCreateDirectory:(NSString *)directoryPath completionBlock:(MLNUIBlock *)completion
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

+ (void)luaui_asyncDelete:(NSString *)path completionBlock:(MLNUIBlock *)completion
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

+ (void)luaui_asyncMoveFile:(NSString *)srcPath destPath:(NSString *)dstPath completionBlock:(MLNUIBlock *)completion
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

+ (void)luaui_asyncCopyFile:(NSString *)srcPath destPath:(NSString *)dstPath completionBlock:(MLNUIBlock *)completion
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

+ (void)luaui_getFileList:(NSString *)dstPath recursive:(BOOL)recursive completionBlock:(MLNUIBlock *)completion
{
    MLNUIKitLuaStaticAssert(dstPath && dstPath.length > 0, @"The path must not be nil!");
    MLNUIStaticCheckTypeAndNilValue(completion, @"callback", MLNUIBlock);
    if (!(dstPath && dstPath.length > 0)) {
        return;
    }
    NSString *realDirPath = [self realPath:dstPath];
    BOOL dirExist = [self existAtPath:realDirPath] && [self luaui_isDirectory:realDirPath];
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

+ (NSMutableDictionary *)luaui_getFileInfo:(NSString *)filePath
{
    BOOL isBlankPath = filePath && filePath.length > 0;
    MLNUIKitLuaStaticAssert(isBlankPath, @"The filePath must not be nil!");
    if (!isBlankPath) {
        return nil;
    }
    BOOL fileExist = [self existAtPath:filePath] && [self luaui_isFile:filePath];
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

+ (void)luaui_asyncReadFileMD5With:(NSString *)filePath completion:(MLNUIBlock *)completion
{
    MLNUIKitLuaStaticAssert(filePath && filePath.length > 0, @"The path must not be nil!");
    MLNUIStaticCheckTypeAndNilValue(completion, @"callback", MLNUIBlock);
    if (!(filePath && filePath.length > 0)) {
        return;
    }
    BOOL fileExist = [self existAtPath:filePath] && [self luaui_isFile:filePath];
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

+ (NSString *)luaui_syncReadFileMD5With:(NSString *)filePath
{
    MLNUIKitLuaStaticAssert(filePath && filePath.length > 0, @"The path must not be nil!");
    if (!(filePath && filePath.length > 0)) {
        return nil;
    }
    BOOL fileExist = [self existAtPath:filePath] && [self luaui_isFile:filePath];
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

+ (NSString *)luaui_applicationRootPath
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

LUAUI_EXPORT_STATIC_BEGIN(MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(exist, "luaui_fileExistAtPath:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(isDir, "luaui_isDirectory:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(isFile, "luaui_isFile:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(syncReadArray, "luaui_fileReadArray:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(syncReadMap, "luaui_fileReadMap:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(syncReadString, "luaui_fileReadString:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(syncWriteFile, "luaui_fileWrite:text:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(syncWriteMap, "luaui_fileWrite:map:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(syncWriteArray, "luaui_fileWrite:array:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(syncUnzipFile, "luaui_unzipFile:targetPath:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncUnzipFile, "luaui_asyncUnzipFile:targetPath:callback:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncWriteArray, "luaui_asyncWriteArray:array:callback:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncWriteMap, "luaui_asyncWriteMap:map:callback:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncWriteFile, "luaui_asyncWriteFile:text:callback:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncReadFile, "luaui_asyncReadFile:callback:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncReadMapFile, "luaui_asyncReadMapFile:callback:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncReadArrayFile, "luaui_asyncReadArrayFile:callback:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(getStorageDir, "luaui_getStorageDir", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncCreateFile, "luaui_asyncCreateFile:completionBlock:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncCreateDirs, "luaui_asyncCreateDirectory:completionBlock:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncDelete, "luaui_asyncDelete:completionBlock:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncMoveFile, "luaui_asyncMoveFile:destPath:completionBlock:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncCopyFile, "luaui_asyncCopyFile:destPath:completionBlock:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncGetFileList, "luaui_getFileList:recursive:completionBlock:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(getFileInfo, "luaui_getFileInfo:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(asyncMd5File, "luaui_asyncReadFileMD5With:completion:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(syncMd5File, "luaui_syncReadFileMD5With:", MLNUIFile)
LUAUI_EXPORT_STATIC_METHOD(rootPath, "luaui_applicationRootPath", MLNUIFile)
LUAUI_EXPORT_STATIC_END(MLNUIFile, File, NO, NULL)

@end
