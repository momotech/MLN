//
//  NSString+MLNUIKit.h
//  
//
//  Created by MoMo on 2019/2/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MLNUIKit)

- (NSString *)mln_md5;

/**
 *  从URL的Query字符串中得到参数的键值对，注意是[URL query]，不是urlString
 *
 *  @return 返回query字符串的参数键值对
 */
- (NSDictionary*)mln_dictionaryFromQuery;

/**
 *  从URL的query字符串获取键为key的值
 *
 *  @param key 参数名称
 *
 *  @return 返回参数对应的值
 */
- (NSString *)mln_queryStringForKey:(NSString *)key;

/**
 *  读取本地文件为NSDictionary
 *
 *  @return 字典对象
 */
- (NSDictionary *)mln_dictionaryWithContentFile;

/**
 获取删除参数后的URL字符串
 
 @return URL字符串
 */
- (NSString *)mln_realURLPath;

@end

NS_ASSUME_NONNULL_END
