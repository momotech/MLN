//
//  MLNFile.h
//  
//
//  Created by MoMo on 2018/7/9.
//

#import <Foundation/Foundation.h>
#import "MLNStaticExportProtocol.h"

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

@end
