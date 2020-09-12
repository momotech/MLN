//
//  MLNUIModelKeyPathComparator.m
//  AFNetworking
//
//  Created by MOMO on 2020/9/2.
//

#import "MLNUIModelKeyPathComparator.h"
#import "MLNUILuaCore.h"
#import "MLNUIModelHandler.h"

#if DEBUG
#define ARGOUI_ERROR_LOG(errMsg) printf("ArgoUI Error: %s\n.", errMsg.UTF8String ?: "(null)");
#else
#define ARGOUI_ERROR_LOG(errMsg)
#endif

@implementation MLNUIModelKeyPathComparator
#if DEBUG

/// 获取是否要对 viewModel 和 服务器返回的数据的 keyPath 进行对比的条件。
/// @param model 从 ArgoUI 里面导出的 viewModel，默认有 isCompareKeyPath 这个方法。
/// @return YES, 进行对比，NO，不进行对比， release 下 YES 也不进行对比。
+ (BOOL)getCompareSwitchWithModel:(nonnull NSObject <MLNUIModelHandlerProtocol>*)model {
    BOOL compareSwitch = NO;
    if ([model respondsToSelector:@selector(isCompareKeyPath)]) {
        compareSwitch = [model isCompareKeyPath];
    }
    return compareSwitch;
}

+ (void)keyPathCompare:(MLNUILuaCore *)luaCore model:(nonnull NSObject <MLNUIModelHandlerProtocol>*)model {
    if (![self getCompareSwitchWithModel:model]) {
        return;
    }
    lua_State *L             = luaCore.state;
    lua_pushvalue(L, -1);
    lua_getglobal(L, "getAllKeyPath");
    lua_insert(L, -2);
    lua_pcall(L, 1, 0, 0);
    lua_getglobal(L, "KeyPathMap");

    NSError      *vmError;
    NSDictionary *keyPathMap = (NSDictionary *) [luaCore toNativeObject:-1 error:&vmError];

    if (vmError) {
        NSString *errMsg = [NSString stringWithFormat:@"The functionChunk called error. (%s)", [vmError localizedDescription].UTF8String];
        ARGOUI_ERROR_LOG(errMsg);
        lua_pop(L, 1);
        return;
    }

    if (!keyPathMap || keyPathMap.allKeys.count == 0) {
        lua_pop(L, 1);
        return;
    }

    if ([model respondsToSelector:@selector(keyPaths)]) {
        NSDictionary *keyPaths = [model keyPaths];
        [self diffBetween:keyPathMap and:keyPaths pk:@""];
    }

    lua_pop(L, 1);
}

+ (void)diffBetween:(NSDictionary *)origin and:(NSDictionary *)standard pk:(NSString *)pk {
    if (!origin) {
        NSLog(@"keyPath compare: %@ 没有赋值", pk);
        return;
    }

    NSString *dot = pk.length > 0 ? @"." : @"";

    [standard enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            if (!origin[key]) {
                NSLog(@"keyPath compare: %@ 没有赋值", [pk stringByAppendingFormat:@"%@%@", dot, key]);
            }
            for (int i = 0; i < [origin[key] count]; ++i) {
                [self diffBetween:origin[key][i] and:obj[0] pk:[pk stringByAppendingFormat:@"%@%@.%d", dot, key, i]];
            }
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            [self diffBetween:origin[key] and:obj pk:[pk stringByAppendingFormat:@"%@%@", dot, key]];
        } else {
            if (![origin.allKeys containsObject:key]) {
                NSLog(@"keyPath compare: %@ 没有赋值", [pk stringByAppendingFormat:@"%@%@", dot, key]);
            }
        }
    }];
}

+ (const char *)luaTableKeyTrackCodeAppendFunction:(const char *)functionChunk model:(nonnull NSObject <MLNUIModelHandlerProtocol>*)model {
    if (![self getCompareSwitchWithModel:model]) {
        return functionChunk;
    }
    NSString *trackCode = [luaTableKeyTrackCode stringByAppendingFormat:@"%s", functionChunk];
    return [trackCode cStringUsingEncoding:NSUTF8StringEncoding];
}

NSString *luaTableKeyTrackCode = @"   KeyPathMap = {}\n"
                                 "    function isArrayTable(t)\n"
                                 "        if type(t) ~= \"table\" then\n"
                                 "            return false\n"
                                 "        end\n"
                                 "        local n = #t\n"
                                 "        for i, v in pairs(t) do\n"
                                 "            if type(i) ~= \"number\" then\n"
                                 "                return false\n"
                                 "            end\n"
                                 "            if i > n then\n"
                                 "                return false\n"
                                 "            end\n"
                                 "        end\n"
                                 "        return true\n"
                                 "    end\n"
                                 "    function checkType(t)\n"
                                 "        local type = type(t);\n"
                                 "        if type == \"userdata\" then\n"
                                 "            return t;\n"
                                 "        end\n"
                                 "        if type == \"number\" then\n"
                                 "            if math.floor(t) < t then\n"
                                 "                return \"float\";\n"
                                 "            else\n"
                                 "                return \"int\";\n"
                                 "            end\n"
                                 "        end\n"
                                 "        if type ~= \"table\" then\n"
                                 "            return type;\n"
                                 "        end\n"
                                 "        if isArrayTable(t) then\n"
                                 "            return \"array\";\n"
                                 "        end\n"
                                 "        return \"map\";\n"
                                 "    end\n"
                                 "    \n"
                                 "    viewModelMT = {\n"
                                 "        __index = function(t, k)\n"
                                 "            if rawget(t, k) == nil then\n"
                                 "                t[k] = {}\n"
                                 "            end\n"
                                 "            return rawget(t, k)\n"
                                 "        end,\n"
                                 "    \n"
                                 "        __newindex = function(t, k, v)\n"
                                 "            _innerSet(t, k, v, \"\")\n"
                                 "        end\n"
                                 "    }\n"
                                 "    \n"
                                 "    function _innerSet(t, k, v, pk)\n"
                                 "    \n"
                                 "        if checkType(v) == \"array\" and #v == 0 then\n"
                                 "            rawset(t, k, v)\n"
                                 "            return\n"
                                 "        end\n"
                                 "    \n"
                                 "        if checkType(v) == \"array\" and #v > 0 then\n"
                                 "            local es = _innerArraySet(t, k, v, k)\n"
                                 "            KeyPathMap[k] = es\n"
                                 "        elseif checkType(v) == \"map\" then\n"
                                 "            local es = _innerMapSet(t, k, v, k)\n"
                                 "            KeyPathMap[k] = es\n"
                                 "        else\n"
                                 "            rawset(t, k, v)\n"
                                 "            local kp = k\n"
                                 "            KeyPathMap[k] = k\n"
                                 "        end\n"
                                 "    end\n"
                                 "    \n"
                                 "    function _innerArraySet(t, k, v, pk)\n"
                                 "        local elementKeys = {}\n"
                                 "        if t[k] == nil then\n"
                                 "            rawset(t, k, {})\n"
                                 "        end\n"
                                 "        for index, value in ipairs(v) do\n"
                                 "            local kp = pk .. \".\" .. \"array\"\n"
                                 "            if checkType(value) == \"array\" then\n"
                                 "                local es = _innerArraySet(t[k], index, value, kp)\n"
                                 "                table.insert(elementKeys, #elementKeys + 1, es)\n"
                                 "            elseif checkType(value) == \"map\" then\n"
                                 "                local es = _innerMapSet(t[k], index, value, kp)\n"
                                 "                table.insert(elementKeys, #elementKeys + 1, es)\n"
                                 "            else\n"
                                 "                rawset(t[k], index, value)\n"
                                 "            end\n"
                                 "        end\n"
                                 "        return elementKeys\n"
                                 "    end\n"
                                 "    \n"
                                 "    function _innerMapSet(t, k, v, pk)\n"
                                 "        local elementKeys = {}\n"
                                 "        if t[k] == nil then\n"
                                 "            rawset(t, k, {})\n"
                                 "        end\n"
                                 "        for key, value in pairs(v) do\n"
                                 "            if checkType(value) == \"array\" then\n"
                                 "                local es = _innerArraySet(t[k], key, value, pk .. \".\" .. tostring(key))\n"
                                 "                elementKeys[key] = es\n"
                                 "            elseif checkType(value) == \"map\" then\n"
                                 "                local es = _innerMapSet(t[k], key, value, pk .. \".\" .. tostring(key))\n"
                                 "                elementKeys[key] = es\n"
                                 "            else\n"
                                 "                elementKeys[key] = key\n"
                                 "                rawset(t[k], key, value)\n"
                                 "            end\n"
                                 "        end\n"
                                 "        return elementKeys\n"
                                 "    end\n"
                                 "    function getAllKeyPath(viewModel)\n"
                                 "        local tmp = {}\n"
                                 "        setmetatable(tmp, viewModelMT)\n"
                                 "        for i, v in pairs(viewModel) do\n"
                                 "            tmp[i] = v\n"
                                 "        end\n"
                                 "    end\n\n";

#endif
@end
