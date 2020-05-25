//
//  MLNUIFile.h
//
//
//  Created by MoMo on 2018/7/9.
//

#import <Foundation/Foundation.h>
#import "MLNUIStaticExportProtocol.h"

typedef NS_ENUM(NSInteger, MLNUIFileErrorCode) {
    MLNUIFileErrorCodeFileNotExist = -1,
    MLNUIFileErrorCodeNotFile = -2,
    MLNUIFileErrorCodeReadFailed = -3,
    MLNUIFileErrorCodeParseJsonFailed = -4,
    MLNUIFileErrorCodeCreateDirFailed = -5,
    MLNUIFileErrorCodeWriteFailed = -6,
    MLNUIFileErrorCodeSourceFileNotExist = -7,
    MLNUIFileErrorCodeCreateFileFailed = -8,
    MLNUIFileErrorCodeDeleteFileFailed = -9,
    MLNUIFileErrorCodeMoveFileFailed = -10,
    MLNUIFileErrorCodeCopyFileFailed = -11,
    MLNUIFileErrorCodeGetFileListFailed = -12,
    MLNUIFileErrorCodeGetFileMD5ParseFailed = -13
};

@interface MLNUIFile : NSObject <MLNUIStaticExportProtocol>

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
