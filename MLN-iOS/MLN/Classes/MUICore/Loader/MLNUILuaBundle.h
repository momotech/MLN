//
//  MLNBundle.h
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNLuaBundle : NSObject

/**
 创建基于Main Bundle目录的lua bundle

 @return lua bundle
 */
+ (instancetype)mainBundle;

/**
 创建基于Main Bundle目录的lua bundle
 
 @param path 相对Library目录的路径
 @return lua bundle
 */
+ (instancetype)mainBundleWithPath:(NSString *)path;

/**
 创建基于Library目录的lua bundle

 @param path 相对Library目录的路径
 @return lua bundle
 */
+ (instancetype)bundleLibraryWithPath:(NSString *)path;

/**
 创建基于Documents目录的lua bundle

 @param path 相对Documents目录的路径
 @return lua bundle
 */
+ (instancetype)bundleDocumentsWithPath:(NSString *)path;

/**
 创建基于Caches目录的lua bundle

 @param path 相对Caches目录的路径
 @return lua bundle
 */
+ (instancetype)bundleCachesWithPath:(NSString *)path;


/**
 初始化一个lua bundle
 
 @param bundlePath 对应的bundle的全路径
 @return lua bundle
 */
- (instancetype)initWithBundlePath:(NSString *)bundlePath;

/**
 初始化一个lua bundle

 @param bundle 对应的bundle对象
 @return lua bundle
 */
- (instancetype)initWithBundle:(NSBundle *)bundle;

/**
 获取文件的完整路径，如果不存在则返回空。

 @param name 文件名或相对路径
 @return 文件的完整路径
 */
- (NSString *)filePathWithName:(NSString *)name;

/**
 获取Path路径

 @return Path路径
 */
- (NSString *)bundlePath;

@end

NS_ASSUME_NONNULL_END
