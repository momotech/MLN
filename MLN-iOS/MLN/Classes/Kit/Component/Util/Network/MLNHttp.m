//
//  MLNHttp.m
//  MLN
//
//  Created by MoMo on 2019/8/3.
//

#import "MLNHttp.h"
#import "MLNKitInstanceHandlersManager.h"
#import "MLNHttpHandlerProtocol.h"
#import "MLNBlock.h"
#import "MLNKitHeader.h"
#import "MLNHttpDefaultHandler.h"


@interface MLNHttp ()

@property (nonatomic, strong) NSMutableSet *mCachePolicyFilterKeySets;

@end

@implementation MLNHttp

static id<MLNHttpHandlerProtocol> defaultHttpHandler = nil;
- (id<MLNHttpHandlerProtocol>)getHandler
{
    id<MLNHttpHandlerProtocol> handler = MLN_KIT_INSTANCE(self.mln_luaCore).instanceHandlersManager.httpHandler;
    if (!handler) {
        handler = [[MLNHttpDefaultHandler alloc] init];
        defaultHttpHandler = handler;
    }
    return handler;
}

- (void)lua_setBaseUrlString:(NSString *)baseUrlString
{
    self.baseUrlString = baseUrlString;
    if ([[self getHandler] respondsToSelector:@selector(http:setBaseUrlString:)]) {
        [[self getHandler] http:self setBaseUrlString:baseUrlString];
    }
}

- (void)addCachePolicyFilterKey:(NSString *)key
{
    MLNKitLuaAssert(key, @"CachePolicyFilterKey must not be nil!");
    if ([[self getHandler] respondsToSelector:@selector(http:addCachePolicyFilterKey:)]) {
        [[self getHandler] http:self addCachePolicyFilterKey:key];
    }
}

- (void)get:(NSString *)urlString params:(NSDictionary *)params completionHandler:(MLNBlock *)completionHandler
{
    MLNLuaAssert(self.mln_luaCore, stringNotEmpty(urlString), @"url must not  be null");
    [[self getHandler] http:self get:urlString params:params completionHandler:^(BOOL success, NSDictionary *respInfo, NSDictionary *errorInfo) {
        if (completionHandler) {
            doInMainQueue([completionHandler addBOOLArgument:success];
                          [completionHandler addObjArgument:respInfo.mutableCopy];
                          [completionHandler addObjArgument:errorInfo.mutableCopy];
                          [completionHandler callIfCan];);
        }
    }];
}

- (void)post:(NSString *)urlString params:(NSDictionary *)params completionHandler:(MLNBlock *)completionHandler
{
    MLNLuaAssert(self.mln_luaCore, stringNotEmpty(urlString), @"url must not  be null");
    [[self getHandler] http:self post:urlString params:params completionHandler:^(BOOL success, NSDictionary *respInfo, NSDictionary *errorInfo) {
        if (completionHandler) {
            doInMainQueue([completionHandler addBOOLArgument:success];
                          [completionHandler addObjArgument:respInfo.mutableCopy];
                          [completionHandler addObjArgument:errorInfo.mutableCopy];
                          [completionHandler callIfCan];);
        }
    }];
}

- (void)download:(NSString *)urlString params:(NSDictionary *)params progressHandler:(MLNBlock *)progressHandler completionHandler:(MLNBlock *)completionHandler
{
    MLNLuaAssert(self.mln_luaCore, stringNotEmpty(urlString), @"url must not  be null");
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

- (void)upload:(NSString *)urlString params:(NSDictionary *)params filePaths:(NSArray *)filePaths fileNames:(NSArray *)fileNames completionHandler:(MLNBlock *)completionHandler
{
    MLNLuaAssert(self.mln_luaCore, stringNotEmpty(urlString), @"url must not  be null");
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
- (void)mln_download:(NSString *)urlString params:(NSDictionary *)params progressHandler:(void(^)(float progress, float total))progressHandler completionHandler:(void(^)(BOOL success, NSDictionary *respInfo, id respData, NSDictionary *errorInfo))completionHandler
{
    MLNLuaAssert(self.mln_luaCore, stringNotEmpty(urlString), @"url must not  be null");
    if ([[self getHandler] respondsToSelector:@selector(http:download:params:progressHandler:completionHandler:)]) {
        [[self getHandler] http:self download:urlString params:params progressHandler:progressHandler completionHandler:completionHandler];
    }
}

#pragma mark - Setup For Lua
LUA_EXPORT_BEGIN(MLNHttp)
LUA_EXPORT_METHOD(setBaseUrl, "lua_setBaseUrlString:", MLNHttp)
LUA_EXPORT_METHOD(addCachePolicyFilterKey, "addCachePolicyFilterKey:", MLNHttp)
LUA_EXPORT_METHOD(get, "get:params:completionHandler:", MLNHttp)
LUA_EXPORT_METHOD(post, "post:params:completionHandler:", MLNHttp)
LUA_EXPORT_METHOD(download, "download:params:progressHandler:completionHandler:", MLNHttp)
LUA_EXPORT_METHOD(upload, "upload:params:filePaths:fileNames:completionHandler:", MLNHttp)
LUA_EXPORT_END(MLNHttp, Http, NO, NULL, NULL)

@end
