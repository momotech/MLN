//
//  MLNUIStringUtil.m
//
//
//  Created by MoMo on 2018/10/11.
//

#import "MLNUIStringUtil.h"
#import "MLNUIKitHeader.h"
#import "MLNUIStaticExporterMacro.h"
#import "NSString+MLNUIKit.h"

@implementation MLNUIStringUtil

+ (NSInteger)lua_length:(NSString *)string
{
    if (!string) return 0;
    return string.length;
}

+ (NSMutableDictionary *)lua_jsonToMap:(NSString*)string {
    MLNUIStaticCheckTypeAndNilValue(string, @"string", NSString)
    if (!(string && [string isKindOfClass:[NSString class]])) {
        return nil;
    }
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        MLNUIKitLuaStaticAssert(NO, @"json解析失败：%@",err);
        return nil;
    }
    return dic.mutableCopy;
}

+ (NSString*)lua_mapToJson:(NSDictionary*)dict {
    MLNUIStaticCheckTypeAndNilValue(dict, @"Map", NSMutableDictionary)
    if (!(dict && [dict isKindOfClass:[NSDictionary class]])) {
        return nil;
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (jsonData) {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        MLNUIKitLuaStaticAssert(NO, @"%@",error);
    }
    return jsonString;
}

+ (NSArray *)lua_jsonToArray:(NSString *)string
{
    MLNUIStaticCheckTypeAndNilValue(string, @"string", [NSString class])
    if (!(string && [string isKindOfClass:[NSString class]])) {
        return nil;
    }
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id tmp = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    if(err) {
        MLNUIKitLuaStaticAssert(NO, @"json解析失败：%@",err);
        return nil;
    }
    if (tmp) {
        if ([tmp isKindOfClass:[NSArray class]])
        {
            return [tmp mutableCopy];
        }
        else {
            return nil;
        }
    }
    return nil;
}

+ (NSString *)lua_arrayToJson:(NSArray *)array
{
    MLNUIStaticCheckTypeAndNilValue(array, @"Array", [NSMutableArray class])
    if (!(array && [array isKindOfClass:[NSArray class]])) {
        return nil;
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        MLNUIKitLuaStaticAssert(NO, @"json解析失败：%@", error);
    }
    return jsonString;
}

#pragma mark - 字符串处理
+ (BOOL)constraintString:(NSString *)str specifiedLength:(NSUInteger)maxCount
{
    BOOL result = NO;
    NSUInteger count = 0;
    for(NSUInteger i = 0; i < [str length]; i++) {
        int a = [str characterAtIndex:i];
        if ( a >= 0 && a <= 127) {
            count ++;
        } else {
            count += 2;
        }
        
        if (count >= maxCount) {
            result = YES;
            return result;
        }
    }
    
    return result;
}

+ (NSString *)constrainString:(NSString *)string toMaxLength:(NSUInteger)maxLength
{
    //截取用户名字,注意中英文的情况
    NSUInteger count = 0;
    NSString *str = string;
    
    for(NSUInteger i = 0; i< [str length]; i++) {
        int a = [str characterAtIndex:i];
        if( a >= 0 && a <= 127) {
            count ++;
        } else {
            count += 2;
        }
        if (count > maxLength) {
            NSRange range = [str rangeOfComposedCharacterSequenceAtIndex:i];
            string = [str substringToIndex:range.location ];
            break;
        }
    }
    return string;
}

+ (CGSize)lua_sizeWithContent:(NSString *)content fontSize:(CGFloat)fontSize
{
    return [content sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]}];
}

+ (CGSize)lua_sizeWithContent:(NSString *)content fontName:(NSString *)fontName size:(CGFloat)fontSize
{
    UIFont* font = [UIFont fontWithName:fontName size:fontSize];
    if (!font) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    return [content sizeWithAttributes:@{NSFontAttributeName : font}];
}

+ (NSString *)lua_md5:(NSString *)string
{
    return [string mln_md5];
}

#pragma mark - Setup For Lua

LUA_EXPORT_STATIC_BEGIN(MLNUIStringUtil)
LUA_EXPORT_STATIC_METHOD(length, "lua_length:", MLNUIStringUtil)
LUA_EXPORT_STATIC_METHOD(jsonToMap, "lua_jsonToMap:", MLNUIStringUtil)
LUA_EXPORT_STATIC_METHOD(mapToJSON, "lua_mapToJson:", MLNUIStringUtil)
LUA_EXPORT_STATIC_METHOD(jsonToArray, "lua_jsonToArray:", MLNUIStringUtil)
LUA_EXPORT_STATIC_METHOD(arrayToJSON, "lua_arrayToJson:", MLNUIStringUtil)
LUA_EXPORT_STATIC_METHOD(sizeWithContentFontSize, "lua_sizeWithContent:fontSize:", MLNUIStringUtil)
LUA_EXPORT_STATIC_METHOD(sizeWithContentFontNameSize, "lua_sizeWithContent:fontName:size:", MLNUIStringUtil)
LUA_EXPORT_STATIC_METHOD(md5, "lua_md5:", MLNUIStringUtil)
LUA_EXPORT_STATIC_END(MLNUIStringUtil, StringUtil, NO, NULL)

@end
