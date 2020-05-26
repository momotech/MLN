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

+ (NSInteger)luaui_length:(NSString *)string
{
    if (!string) return 0;
    return string.length;
}

+ (NSMutableDictionary *)luaui_jsonToMap:(NSString*)string {
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

+ (NSString*)luaui_mapToJson:(NSDictionary*)dict {
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

+ (NSArray *)luaui_jsonToArray:(NSString *)string
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

+ (NSString *)luaui_arrayToJson:(NSArray *)array
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

+ (CGSize)luaui_sizeWithContent:(NSString *)content fontSize:(CGFloat)fontSize
{
    return [content sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]}];
}

+ (CGSize)luaui_sizeWithContent:(NSString *)content fontName:(NSString *)fontName size:(CGFloat)fontSize
{
    UIFont* font = [UIFont fontWithName:fontName size:fontSize];
    if (!font) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    return [content sizeWithAttributes:@{NSFontAttributeName : font}];
}

+ (NSString *)luaui_md5:(NSString *)string
{
    return [string mlnui_md5];
}

#pragma mark - Setup For Lua

LUAUI_EXPORT_STATIC_BEGIN(MLNUIStringUtil)
LUAUI_EXPORT_STATIC_METHOD(length, "luaui_length:", MLNUIStringUtil)
LUAUI_EXPORT_STATIC_METHOD(jsonToMap, "luaui_jsonToMap:", MLNUIStringUtil)
LUAUI_EXPORT_STATIC_METHOD(mapToJSON, "luaui_mapToJson:", MLNUIStringUtil)
LUAUI_EXPORT_STATIC_METHOD(jsonToArray, "luaui_jsonToArray:", MLNUIStringUtil)
LUAUI_EXPORT_STATIC_METHOD(arrayToJSON, "luaui_arrayToJson:", MLNUIStringUtil)
LUAUI_EXPORT_STATIC_METHOD(sizeWithContentFontSize, "luaui_sizeWithContent:fontSize:", MLNUIStringUtil)
LUAUI_EXPORT_STATIC_METHOD(sizeWithContentFontNameSize, "luaui_sizeWithContent:fontName:size:", MLNUIStringUtil)
LUAUI_EXPORT_STATIC_METHOD(md5, "luaui_md5:", MLNUIStringUtil)
LUAUI_EXPORT_STATIC_END(MLNUIStringUtil, StringUtil, NO, NULL)

@end
