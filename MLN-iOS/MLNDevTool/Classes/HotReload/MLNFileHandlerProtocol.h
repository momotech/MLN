//
//  MLNFileHandlerProtocol.h
//  MLNDebugger
//
//  Created by MoMo on 2019/8/21.
//

#ifndef MLNFileHandlerProtocol_h
#define MLNFileHandlerProtocol_h
#import <Foundation/Foundation.h>

@protocol MLNFileHandlerProtocol <NSObject>

/**
 创建文件或文件夹

 @param filePath 文件的路径
 @param relativeFilePath 文件的相对路径
 @param fileData 文件的内容
 */
- (void)createFile:(NSString *)filePath relativeFilePath:(NSString *)relativeFilePath fileData:(NSData *)fileData;

/**
 更新文件内容

 @param filePath 文件的路径
 @param relativeFilePath 文件的相对路径
 @param fileData 文件的内容
 */
- (void)updateFile:(NSString *)filePath relativeFilePath:(NSString *)relativeFilePath fileData:(NSData *)fileData;

/**
 文件或文件夹重命名

 @param filePath 文件的路径
 @param relativeFilePath 文件的相对路径
 @param newFilePath 新的文件的路径
 @param relativeNewFilePath 新的文件的相对路径
 */
- (void)renameFile:(NSString *)filePath relativeFilePath:(NSString *)relativeFilePath newFilePath:(NSString *)newFilePath relativeNewFilePath:(NSString *)relativeNewFilePath;

/**
 移动文件或文件夹
 
 @param filePath 文件的路径
 @param relativeFilePath 文件的相对路径
 @param newFilePath 新的文件的路径
 @param relativeNewFilePath 新的文件的相对路径
 */
- (void)moveFile:(NSString *)filePath relativeFilePath:(NSString *)relativeFilePath newFilePath:(NSString *)newFilePath relativeNewFilePath:(NSString *)relativeNewFilePath;

/**
 删除文件或文件夹

 @param filePath 文件的路径
 @param relativeFilePath 文件的相对路径
 */
- (void)deleteFile:(NSString *)filePath relativeFilePath:(NSString *)relativeFilePath;

@end

#endif /* MLNFileHandlerProtocol_h */
