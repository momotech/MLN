//
//  MLNThread.m
//  MLNDevTool
//
//  Created by MOMO on 2020/1/6.
//

#import "MLNThread.h"
#import <MLN/MLNColor.h>
#import <MLN/MLNHttp.h>
#import <MLN/MLNTimer.h>
#import <MLN/MLNBit.h>
#import <MLN/MLNFile.h>
#import <MLN/MLNStyleString.h>
#import <MLN/MLNTypeUtil.h>
#import <MLN/MLNStringUtil.h>
#import <MLN/MLNNetworkReachability.h>
#import <MLN/MLNCore.h>

#define FORCE_INLIEN __inline__ __attribute__((always_inline))

static NSArray *BridgeClasses(void) {
    return @[[MLNColor class],
             [MLNHttp class],
             [MLNTimer class],
             [MLNBit class],
             [MLNFile class],
             [MLNStyleString class],
             [MLNTypeUtil class],
             [MLNStringUtil class],
             [MLNNetworkReachability class],
             [NSMutableDictionary class],
             [NSMutableArray class]];
}

static NSMutableDictionary<NSString *, MLNLuaCore *> *Cache(void) {
    static NSMutableDictionary *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSMutableDictionary dictionary];
    });
    return cache;
}

static dispatch_semaphore_t _semaphore(void) {
    static dispatch_semaphore_t st = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        st = dispatch_semaphore_create(1);
    });
    return st;
}

static FORCE_INLIEN void Lock(void) {
    dispatch_semaphore_wait(_semaphore(), DISPATCH_TIME_FOREVER);
}

static FORCE_INLIEN void Unlock(void) {
    dispatch_semaphore_signal(_semaphore());
}

static FORCE_INLIEN NSString *toKey(lua_State *L) {
    if (L) {
        return [NSString stringWithFormat:@"%p", L];
    }
    return @"";
}

lua_State *mln_create_vm_in_subthread(void) {
    Lock();
    MLNLuaCore *core = [[MLNLuaCore alloc] init];
    [Cache() setObject:core forKey:toKey(core.state)];
    [core registerClasses:BridgeClasses() error:nil];
    Unlock();
    return core.state;
}

static int MLN_package_loader(lua_State *L) {
    NSString *fileName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    if (fileName && fileName.length >0) {
        NSString *filePath = [fileName stringByReplacingOccurrencesOfString:@"." withString:@"/"];
        NSString *fullPath = [MLN_LUA_CORE(L).currentBundle filePathWithName:[NSString stringWithFormat:@"%@.lua",filePath]];
        BOOL success = [MLN_LUA_CORE(L) loadFile:fullPath error:nil];
        return success ? 1 : 0;
    }
    return 1;
}

void mln_set_vm_bundle_path(lua_State *PL, lua_State *L) {
    if (PL == nil || L == nil) {
        return;
    }
    
    MLNLuaCore *parentCore = MLN_LUA_CORE(PL);
    MLNLuaCore *childCore = MLN_LUA_CORE(L);
    if (childCore.currentBundle == parentCore.currentBundle) {
        return;
    }
    [childCore changeLuaBundle:parentCore.currentBundle];
    
    lua_getglobal(L, "package");    // L: package
    lua_getfield(L, -1, "loaders"); // L: package, loaders
    lua_pushcfunction(L, MLN_package_loader); // L: package, loaders, func
    for (int i = (int)lua_objlen(L, -2) + 1; i > 2; --i) {
        lua_rawgeti(L, -2, i - 1); // L: package, loaders, func, function
        lua_rawseti(L, -3, i);     // L: package, loaders, func
    }
    lua_rawseti(L, -2, 2);  // L: package, loaders
    lua_setfield(L, -2, "loaders"); // L: package
    lua_pop(L, 1);
}

void mln_release_vm_in_subthread(lua_State *L) {
    Lock();
    [Cache() removeObjectForKey:toKey(L)];
    Unlock();
}
