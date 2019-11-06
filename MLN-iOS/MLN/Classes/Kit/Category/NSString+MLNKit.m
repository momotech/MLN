//
//  NSString+MLNKit.m
//  
//
//  Created by MoMo on 2019/2/15.
//

#import "NSString+MLNKit.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (MLNKit)

- (NSString *)mln_md5
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
