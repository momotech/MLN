//
//  MLNViewDefaultURLParseInspector.m
//  MLNKit
//
//  Created by LiYong on 2022/1/13.
//

#import "MLNLuaViewDefaultURLParseInspector.h"
#import "MLNViewLoadModel.h"

@implementation MLNLuaViewDefaultURLParseInspector

#pragma mark - MLNInspector
- (void)execute:(MLNViewLoadModel *)loadModel
{
    NSMutableDictionary *params = [self getUrlParameterWithUrl:loadModel.urlStr];
    loadModel.windowExtro[@"urlParams"] = params;
    if (loadModel.forceLocal) {
        params[@"forceLocal"] = @(loadModel.forceLocal);
    }
    [loadModel setValuesForKeysWithDictionary:params];
    if ([loadModel.urlStr containsString:@"?"]) {
        loadModel.url64 = [loadModel.urlStr componentsSeparatedByString:@"?"].firstObject;
    } else {
        loadModel.url64 = loadModel.urlStr;
    }
}

- (NSMutableDictionary *)getUrlParameterWithUrl:(NSString *)url {
    NSString *encodingUrlString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableDictionary *parm = @{}.mutableCopy;
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:encodingUrlString];
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        parm[obj.name] = obj.value;
    }];
    return parm;
}

@end
