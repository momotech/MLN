//
//  NSString+MLNUIKit.m
//  
//
//  Created by MoMo on 2019/2/15.
//

#import "NSString+MLNUIKit.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (MLNUIKit)

- (NSDictionary *)mlnui_dictionaryFromQuery {
    NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;#"];
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    NSScanner *scanner = [[NSScanner alloc] initWithString:self];
    
    while (![scanner isAtEnd]) {
        NSString *pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray *kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString *key = [[kvPair objectAtIndex:0] stringByRemovingPercentEncoding];
            NSString *value = [[kvPair objectAtIndex:1] stringByRemovingPercentEncoding];
            [pairs setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}

- (NSString *)mlnui_queryStringForKey:(NSString *)key
{
    NSDictionary *dict = [self mlnui_dictionaryFromQuery];
    if (dict.count) {
        return [dict valueForKey:key];
    }
    return nil;
}

/**
 *  读取本地文件为NSDictionary
 *
 *  @return 字典对象
 */
- (NSDictionary *)mlnui_dictionaryWithContentFile
{
    NSMutableDictionary *jsonDict = nil;
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:self encoding:NSUTF8StringEncoding error:nil];
    if (jsonString.length > 0) {
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (data && [data length]) {
            jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        }
    }
    
    return jsonDict;
}

- (NSString *)mlnui_realURLPath
{
    return [[self componentsSeparatedByString:@"?"] firstObject];
}

- (NSString *)mlnui_md5
{
    const char *str = [self UTF8String];
    if (str == NULL) {
        str = "";
    }
    
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    
    static const char HexEncodeChars[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
    char *resultData = malloc(CC_MD5_DIGEST_LENGTH * 2 + 1);
    
    for (uint index = 0; index < CC_MD5_DIGEST_LENGTH; index++) {
        resultData[index * 2] = HexEncodeChars[(r[index] >> 4)];
        resultData[index * 2 + 1] = HexEncodeChars[(r[index] % 0x10)];
    }
    resultData[CC_MD5_DIGEST_LENGTH * 2] = 0;
    
    NSString *hash = @(resultData);
    
    if (resultData) {
        free(resultData);
    }
    
    return hash;
}

@end
