//
//  MLNPackage.m
//  MMLNua_Example
//
//  Created by MOMO on 2019/11/2.
//  Copyright © 2019年 MOMO. All rights reserved.
//

#import "MLNPackage.h"
#import "MLNActionDefine.h"
#import <NSString+MLNKit.h>
#import "MLNActionItem.h"
#import <MLNFile.h>

@interface MLNPackage()

@property (nonatomic, strong) MLNActionItem *actionItem;

@end

@implementation MLNPackage

- (instancetype)initWithURLString:(NSString *)urlString
{
    if (self = [super init]) {
        _urlString = urlString;
        [self interpretationURLStringIfNeed];
        [self checkFileInfo];
    }
    return self;
}

- (instancetype)initWithActionItem:(MLNActionItem *)actionItem
{
    if (self = [super init]) {
        _actionItem = actionItem;
        if ([actionItem.action hasPrefix:@"{"]) {
            _urlString = [actionItem.actionInfo objectForKey:kMLNURLKey];
            [self interpretationURLStringIfNeed];
        } else if([actionItem.action hasPrefix:@"http"]){
            _urlString = actionItem.action;
            [self interpretationURLStringIfNeed];
        } else {
            NSString *resoucePath = [self resoucePathWith:actionItem];
            _bundlePath = resoucePath.stringByDeletingLastPathComponent;
            _entryFile = resoucePath.lastPathComponent;
        }
        [self checkFileInfo];
    }
    return self;
}

- (instancetype)initWithEntryFile:(NSString *)entryFile bundlePath:(NSString *)bundlePath
{
    if (self = [super init]) {
        _entryFile = entryFile;
        _bundlePath = bundlePath;
    }
    return self;
}

//解析URL字符串
- (void)interpretationURLStringIfNeed
{
    if (_urlString == nil || ![_urlString isKindOfClass:[NSString class]]) {
        return;
    }
    NSURL *URL = [NSURL URLWithString:_urlString];
    NSDictionary *urlParams = [[URL query] mln_dictionaryFromQuery];
    NSString *urlEntryFile = [urlParams objectForKey:kMLNEntryFileKey];
    NSString *prmEntryFile = [_actionItem.actionInfo objectForKey:kMLNEntryFileKey];
    if (!URL) {
        return;
    }
    if (urlEntryFile != nil) {
        _entryFile = urlEntryFile;
    } else if(prmEntryFile){
        _entryFile = prmEntryFile;
    } else {
        _entryFile = URL.lastPathComponent;
    }
    NSString *rootPath = MLNFile.fileManagerRootPath;
    NSString *bundlePath = [rootPath stringByAppendingPathComponent:kMLNRemoteFilePath];
    bundlePath = [bundlePath stringByAppendingPathComponent:[URL host]];
    NSString *path = [URL path];
    if (![path hasSuffix:@".zip"]) {
        _bundlePath = [bundlePath stringByAppendingPathComponent:path.stringByDeletingPathExtension];
    } else {
        _bundlePath = [bundlePath stringByAppendingPathComponent:path.stringByDeletingPathExtension];
    }
    
    //做一下合并，供MLNPackage检查用
    if (_actionItem.actionInfo && urlParams) {
        NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:_actionItem.actionInfo];
        [dictM addEntriesFromDictionary:dictM];
        _actionItem.actionInfo = dictM;
    }
}

//解析本地目录
- (NSString *)resoucePathWith:(MLNActionItem *)actionItem
{
    NSString *entryFile = [self entryFileWIth:actionItem];
    NSString *resourcePath = nil;
    NSString *actionString = [actionItem.action stringByDeletingLastPathComponent];
    actionString = [actionString stringByAppendingPathComponent:entryFile];
    
    if ([actionItem.action hasPrefix:@"file://"]) {//   相对目录情况下，进行目录替换操作
        actionString = [actionString stringByReplacingOccurrencesOfString:@"file:/" withString:@""];
        resourcePath = [[MLNFile fileManagerRootPath] stringByAppendingPathComponent:actionString];
    } else if ([actionString rangeOfString:@"/"].location == NSNotFound) {//没有斜杠，说明没有目录，是个直接的lua文件
        NSString *currentBundlePath = [actionItem.actionInfo objectForKey:kMLNCurrentBundlePath];
        resourcePath = [currentBundlePath stringByAppendingPathComponent:entryFile];
    } else {
        resourcePath = actionString;
    }
    return resourcePath;
}

- (NSString *)entryFileWIth:(MLNActionItem *)actionItem
{
    NSString *entryFile = actionItem.action.lastPathComponent;
    if (![entryFile hasSuffix:@".lua"]) {
        entryFile = [entryFile stringByReplacingOccurrencesOfString:@"." withString:@""];
        entryFile = [entryFile stringByAppendingString:@".lua"];
    }
    return entryFile;
}

- (void)checkFileInfo
{
    if (![_entryFile hasSuffix:@"zip"]) {
        _entryFile = [_entryFile stringByReplacingOccurrencesOfString:@"zip" withString:@"lua"];
    }
    
    NSString *resoucePath = [_bundlePath stringByAppendingPathComponent:_entryFile];
    _needDownload = ![[NSFileManager defaultManager] fileExistsAtPath:resoucePath];
    if ([_actionItem.actionInfo objectForKey:kMLNReloadKey]) {
        _needReload = [[_actionItem.actionInfo objectForKey:kMLNReloadKey] boolValue];
    }
    if (![_entryFile hasSuffix:@".lua"]) {
        _entryFile = [_entryFile stringByAppendingString:@".lua"];
    }
}

@end
