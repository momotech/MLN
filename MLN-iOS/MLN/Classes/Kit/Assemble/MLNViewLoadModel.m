//
//  MLNViewLoadModel.m
//  MLNKit
//
//  Created by xue.yunqiang on 2022/1/4.
//

#import "MLNViewLoadModel.h"

@implementation MLNViewLoadModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
-(NSMutableDictionary *)windowExtro {
    if (!_windowExtro) {
        _windowExtro = [NSMutableDictionary dictionary];
    }
    return _windowExtro;
}

- (NSDictionary *)basicInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:10];
    info[@"url"] = _urlStr;
    info[@"entryFile"] = _enterFilePath;
    info[@"fullEnterFile"] = _fullEnterFilePath;
    info[@"identfier"] = _identfier;
    info[@"version"] = _version;
    info[@"url64"] = _url64;
    info[@"bundlePath"] = _bundle;
    info[@"retryCount"] = @(_retryCount);
    info[@"fileFullPath"] = _fileFullPath;
    info[@"business"] = _business;
    info[@"identifier"] = _identfier;
    info[@"luaCore"] = _windowExtro[@"identifier"];
    return info;
}
@end
