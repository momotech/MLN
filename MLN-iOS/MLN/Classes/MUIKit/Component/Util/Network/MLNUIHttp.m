//
//  MLNUIHttp.m
//  MLNUI
//
//  Created by MoMo on 2019/8/3.
//

#import "MLNUIHttp.h"
#import "MLNUIKitInstanceHandlersManager.h"
#import "MLNUIHttpHandlerProtocol.h"
#import "MLNUIBlock.h"
#import "MLNUIKitHeader.h"
#import "MLNUIHttpDefaultHandler.h"


@interface MLNUIHttp ()

@property (nonatomic, strong) NSMutableSet *mCachePolicyFilterKeySets;

@end

@implementation MLNUIHttp

static id<MLNUIHttpHandlerProtocol> defaultHttpHandler = nil;
- (id<MLNUIHttpHandlerProtocol>)getHandler
{
    id<MLNUIHttpHandlerProtocol> handler = MLNUI_KIT_INSTANCE(self.mlnui_luaCore).instanceHandlersManager.httpHandler;
    if (!handler) {
        handler = [[MLNUIHttpDefaultHandler alloc] init];
        defaultHttpHandler = handler;
    }
    return handler;
}

- (void)luaui_setBaseUrlString:(NSString *)baseUrlString
{
    self.baseUrlString = baseUrlString;
    if ([[self getHandler] respondsToSelector:@selector(http:setBaseUrlString:)]) {
        [[self getHandler] http:self setBaseUrlString:baseUrlString];
    }
}

- (void)addCachePolicyFilterKey:(NSString *)key
{
    MLNUIKitLuaAssert(key, @"CachePolicyFilterKey must not be nil!");
    if ([[self getHandler] respondsToSelector:@selector(http:addCachePolicyFilterKey:)]) {
        [[self getHandler] http:self addCachePolicyFilterKey:key];
    }
}

- (void)get:(NSString *)urlString params:(NSDictionary *)params completionHandler:(MLNUIBlock *)completionHandler
{
    MLNUILuaAssert(self.mlnui_luaCore, stringNotEmpty(urlString), @"url must not  be null");
    [[self getHandler] http:self get:urlString params:params completionHandler:^(BOOL success, NSDictionary *respInfo, NSDictionary *errorInfo) {
        if (completionHandler) {
            doInMainQueue([completionHandler addBOOLArgument:success];
                          [completionHandler addObjArgument:respInfo.mutableCopy];
                          [completionHandler addObjArgument:errorInfo.mutableCopy];
                          [completionHandler callIfCan];);
        }
    }];
}

- (void)post:(NSString *)urlString params:(NSDictionary *)params completionHandler:(MLNUIBlock *)completionHandler
{
    MLNUILuaAssert(self.mlnui_luaCore, stringNotEmpty(urlString), @"url must not  be null");
    [[self getHandler] http:self post:urlString params:params completionHandler:^(BOOL success, NSDictionary *respInfo, NSDictionary *errorInfo) {
        if (completionHandler) {
            doInMainQueue([completionHandler addBOOLArgument:success];
                          [completionHandler addObjArgument:respInfo.mutableCopy];
                          [completionHandler addObjArgument:errorInfo.mutableCopy];
                          [completionHandler callIfCan];);
        }
    }];
}

- (void)download:(NSString *)urlString params:(NSDictionary *)params progressHandler:(MLNUIBlock *)progressHandler completionHandler:(MLNUIBlock *)completionHandler
{
    MLNUILuaAssert(self.mlnui_luaCore, stringNotEmpty(urlString), @"url must not  be null");
    [[self getHandler] http:self download:urlString params:params  progressHandler:^(float progress, float total) {
        if (progressHandler) {
            doInMainQueue([progressHandler addFloatArgument:progress];
                          [progressHandler addFloatArgument:total];
                          [progressHandler callIfCan];);
        }
    } completionHandler:^(BOOL success, NSDictionary *respInfo, id respData, NSDictionary *errorInfo) {
        if (completionHandler) {
            doInMainQueue([completionHandler addBOOLArgument:success];
                          [completionHandler addObjArgument:respInfo.mutableCopy];
                          [completionHandler addObjArgument:errorInfo.mutableCopy];
                          [completionHandler callIfCan];);
        }
    }];
}

- (void)upload:(NSString *)urlString params:(NSDictionary *)params filePaths:(NSArray *)filePaths fileNames:(NSArray *)fileNames completionHandler:(MLNUIBlock *)completionHandler
{
    MLNUILuaAssert(self.mlnui_luaCore, stringNotEmpty(urlString), @"url must not  be null");
    [[self getHandler] http:self upload:urlString params:params filePaths:filePaths  fileNames:fileNames completionHandler:^(BOOL success, NSDictionary *respInfo, NSDictionary *errorInfo) {
        if (completionHandler) {
            doInMainQueue([completionHandler addBOOLArgument:success];
                          [completionHandler addObjArgument:respInfo.mutableCopy];
                          [completionHandler addObjArgument:errorInfo.mutableCopy];
                          [completionHandler callIfCan];);
        }
    }];
}

#pragma mark - Public method
- (void)mlnui_download:(NSString *)urlString params:(NSDictionary *)params progressHandler:(void(^)(float progress, float total))progressHandler completionHandler:(void(^)(BOOL success, NSDictionary *respInfo, id respData, NSDictionary *errorInfo))completionHandler
{
    MLNUILuaAssert(self.mlnui_luaCore, stringNotEmpty(urlString), @"url must not  be null");
    if ([[self getHandler] respondsToSelector:@selector(http:download:params:progressHandler:completionHandler:)]) {
        [[self getHandler] http:self download:urlString params:params progressHandler:progressHandler completionHandler:completionHandler];
    }
}

#pragma mark - Setup For Lua
LUA_EXPORT_BEGIN(MLNUIHttp)
LUA_EXPORT_METHOD(setBaseUrl, "luaui_setBaseUrlString:", MLNUIHttp)
LUA_EXPORT_METHOD(addCachePolicyFilterKey, "addCachePolicyFilterKey:", MLNUIHttp)
LUA_EXPORT_METHOD(get, "get:params:completionHandler:", MLNUIHttp)
LUA_EXPORT_METHOD(post, "post:params:completionHandler:", MLNUIHttp)
LUA_EXPORT_METHOD(download, "download:params:progressHandler:completionHandler:", MLNUIHttp)
LUA_EXPORT_METHOD(upload, "upload:params:filePaths:fileNames:completionHandler:", MLNUIHttp)
LUA_EXPORT_END(MLNUIHttp, Http, NO, NULL, NULL)

@end
