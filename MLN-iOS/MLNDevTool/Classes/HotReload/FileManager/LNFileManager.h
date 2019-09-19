//
//  MLNFileManager.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNFileManager : NSObject


/**
 入口文件的绝对路径（远端工程内的绝对路径）
 */
@property (nonatomic, copy, readonly) NSString *entryFilePath;

/**
 入口文件的相对路径（远端工程内的相对路径）
 */
@property (nonatomic, copy, readonly) NSString *relativeEntryFilePath;

/**
 当前lua运行的bundle路径
 */
@property (nonatomic, copy, readonly) NSString *luaBundlePath;

/**
 所有lua的bundle存储的根路径
 */
@property (nonatomic, copy, readonly) NSString *hotReloadBundlePath;

/**
 更新入口文件
 
 @param entryFilePath 入口文件的绝对路径（远端工程内的绝对路径）
 @param relativeFilePath 入口文件的相对路径（远端工程内的相对路径）
 */
- (void)updateEntryFilePath:(NSString *)entryFilePath relativeFilePath:(NSString *)relativeFilePath;

/**
 更新当前的lua运行bundle根路径
 */
- (void)updateLuaBundlePath;

/**
 更新lua文件
 
 @param filePath 入口文件的绝对路径（远端工程内的绝对路径）
 @param relativeFilePath 文件的相对路径（远端工程内的相对路径）
 @param data 文件内容
 @return 是否更新成功
 */
- (BOOL)updateFile:(NSString *)filePath relativeFilePath:(NSString *)relativeFilePath data:(NSData *)data;

/**
 删除文件
 
 @param filePath 文件的绝对路径（远端工程内的绝对路径）
 @return 是否删除成功
 */
- (BOOL)deleteFile:(NSString *)filePath;

/**
 重命名文件
 
 @param filePath 文件的绝对路径（远端工程内的绝对路径）
 @param newFilePath 新的文件绝对路径（远端工程内的绝对路径）
 @return 是否重命名成功
 */
- (BOOL)renameFile:(NSString *)filePath newFilePath:(NSString *)newFilePath;

/**
 移动文件
 
 @param filePath 文件的绝对路径（远端工程内的绝对路径）
 @param newFilePath 新的文件绝对路径（远端工程内的绝对路径）
 @return 是否移动成功
 */
- (BOOL)moveFile:(NSString *)filePath newFilePath:(NSString *)newFilePath;


@end

NS_ASSUME_NONNULL_END
