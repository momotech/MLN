//
//  MLNFile.h
//
//
//  Created by MoMo on 2018/7/9.
//

#import <Foundation/Foundation.h>
#import "MLNStaticExportProtocol.h"

typedef NS_ENUM(NSInteger, MLNFileErrorCode) {
    MLNFileErrorCodeFileNotExist = -1,
    MLNFileErrorCodeNotFile = -2,
    MLNFileErrorCodeReadFailed = -3,
    MLNFileErrorCodeParseJsonFailed = -4,
    MLNFileErrorCodeCreateDirFailed = -5,
    MLNFileErrorCodeWriteFailed = -6,
    MLNFileErrorCodeSourceFileNotExist = -7,
    MLNFileErrorCodeCreateFileFailed = -8,
    MLNFileErrorCodeDeleteFileFailed = -9,
    MLNFileErrorCodeMoveFileFailed = -10,
    MLNFileErrorCodeCopyFileFailed = -11,
    MLNFileErrorCodeGetFileListFailed = -12,
    MLNFileErrorCodeGetFileMD5ParseFailed = -13
};

@interface MLNFile : NSObject <MLNStaticExportProtocol>

// 根据lua的文件夹相对路径获取实际存储路径
+ (NSString*)directoryWithPath:(NSString*)path;

/**
 设置文件管理的根路径

 @param rootPath 文件管理的根路径
 */
+ (void)setFileManagerRootPath:(NSString *)rootPath;

/**
 获取文件管理的根路径
 
 @return 路径地址
 */
+ (NSString *)fileManagerRootPath;

/**
获取真实的路径
 
@param filePath 文件的相对路径
 @param need 是否需要创建文件目录
@return 路径地址
*/
+ (NSString *)realFilePath:(NSString *)filePath createDirIfNeed:(BOOL)need;

/**
获取真实的路径
@param dirPath 文件的相对路径
@param need 是否需要创建文件目录
@return 路径地址
*/
+ (NSString*)realDirectoryPath:(NSString*)dirPath createDirIfNeed:(BOOL)need;
/**
判断文件是否存在
 
@param path 文件路径
@return 是否存在
*/
+ (BOOL)existAtPath:(NSString *)path;

@end
