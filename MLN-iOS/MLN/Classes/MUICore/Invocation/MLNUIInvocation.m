//
//  MLNUIInvocation.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/30.
//

#import "MLNUIInvocation.h"
#import "MLNUILuaCore.h"
#import "MLNUIConvertor.h"
#import "MLNUIBlock.h"
#import "NSObject+MLNUICore.h"
#import "NSValue+MLNUICore.h"

#pragma mark - Class & Selector

static MLNUI_FORCE_INLINE Class __mln_lua_getclass (lua_State *L) {
    mln_lua_checkstring(L, lua_upvalueindex(1));
    NSString *clazzString = [NSString stringWithUTF8String:lua_tostring(L, lua_upvalueindex(1))];
    mln_lua_assert(L, (clazzString && clazzString.length > 0), @"The first upvalue must be a string of class name!");
    return NSClassFromString(clazzString);
}

static MLNUI_FORCE_INLINE SEL __mln_lua_getselector_at_index (lua_State *L, int idx) {
    mln_lua_checkstring(L, lua_upvalueindex(idx));
    NSString *selectorString = [NSString stringWithUTF8String:lua_tostring(L, lua_upvalueindex(idx))];
    mln_lua_assert(L, (selectorString && selectorString.length > 0), @"The selector name must not be nil!!");
    return NSSelectorFromString(selectorString);
}

static MLNUI_FORCE_INLINE SEL __mln_lua_getselector (lua_State *L) {
    return __mln_lua_getselector_at_index(L, 3);
}

static MLNUI_FORCE_INLINE BOOL __mln_lua_isproperty (lua_State *L) {
    mln_lua_checkboolean(L, lua_upvalueindex(2));
    return lua_toboolean(L, lua_upvalueindex(2));
}

static MLNUI_FORCE_INLINE SEL __mln_lua_getselector_getter (lua_State *L) {
    // setter's index is 3, getter's index is 4
    return __mln_lua_getselector_at_index(L, 4);
}

static MLNUI_FORCE_INLINE SEL __mln_lua_getselector_setter (lua_State *L) {
    // setter's index is 3, getter's index is 4
    return __mln_lua_getselector_at_index(L, 3);
}

static MLNUI_FORCE_INLINE SEL __mln_lua_getproperty_selector (lua_State *L) {
    // 有参数则证明是settera方法
    if ((lua_gettop(L) >=2)) {
        return __mln_lua_getselector_setter(L);
    }
    return __mln_lua_getselector_getter(L);
}

static MLNUI_FORCE_INLINE id __mln_lua_getuserdata_target (lua_State *L) {
    MLNUIUserData *user = (MLNUIUserData *)lua_touserdata(L, 1);
    if (user) {
        id obj = (__bridge id)(user->object);
        if (obj) {
            return obj;
        }
    }
    mln_lua_assert(L, NO, @"The target must not be nil!, you must use “:” to call a method!");
    return nil;
}

#pragma mark - Method Signature

static NSMutableDictionary *__mln_method_signature_caches = nil;
static MLNUI_FORCE_INLINE NSMethodSignature * _mm_objc_method_signature (NSString *s_clazz, NSString *s_selector, id target, SEL selector) {
    NSMethodSignature *sig = nil;
    if (!__mln_method_signature_caches) {
        __mln_method_signature_caches = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *sigs = [__mln_method_signature_caches objectForKey:s_clazz];
    if (!sigs) {
        sigs = [NSMutableDictionary dictionary];
        [__mln_method_signature_caches setObject:sigs forKey:s_clazz];
    }
    sig = [sigs objectForKey:s_selector];
    if (!sig) {
        sig = [target methodSignatureForSelector:selector];
        if (sig) {
            [sigs setObject:sig forKey:s_selector];
        }
    }
    return sig;
}

#pragma mark - Invocation

typedef id(^MLNUICallback)(id result);

static MLNUI_FORCE_INLINE BOOL __mln_lua_setinvocation (lua_State *L, NSInvocation *invocation, NSInteger index, int stackID, NSMutableArray *retainArray) {
    const char *type = [invocation.methodSignature getArgumentTypeAtIndex:index];
    if (!charpNotEmpty(type)) {
        mln_lua_error(L, @"Undefined parameter type！");
        return NO;
    }
    switch (mln_objctype(type)) {
        case MLNUI_OBJCType_BOOL: {
            mln_lua_checkboolean(L, stackID);
            BOOL value = lua_toboolean(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_class: {
            mln_lua_checkstring(L, stackID);
            NSString *clazzName = [MLNUI_LUA_CORE(L) toString:stackID error:NULL];
            if (stringNotEmpty(clazzName)) {
                Class clazz = NSClassFromString(clazzName);
                [invocation setArgument:&clazz atIndex:index];
            } else {
                mln_lua_error(L, @"class name must be null");
            }
            break;
        }
        case MLNUI_OBJCType_block: {
            mln_lua_checkfunc(L, stackID);
            MLNUIBlock *block = nil;
            block = [[MLNUIBlock alloc] initWithLuaCore:MLNUI_LUA_CORE(L) indexOnLuaStack:stackID];
            MLNUICallback callback = [^id(id result){
                return [block callWithParam:result];
            } copy];
            [retainArray addObject:callback];
            [invocation setArgument:&callback atIndex:index];
            break;
        }
        case MLNUI_OBJCType_SEL: {
            mln_lua_checkstring(L, stackID);
            NSString *selName = [MLNUI_LUA_CORE(L) toString:stackID error:NULL];
            if (stringNotEmpty(selName)) {
                SEL selector = NSSelectorFromString(selName);
                [invocation setArgument:&selector atIndex:index];
            } else {
                mln_lua_error(L, @"method name must be null");
            }
            break;
        }
        case MLNUI_OBJCType_id: {
            id nativeObject = [MLNUI_LUA_CORE(L) toNativeObject:stackID error:NULL];
            [invocation setArgument:&nativeObject atIndex:index];
            break;
        }
        case MLNUI_OBJCType_char: {
            if (lua_isboolean(L, stackID)) {
                char value = lua_toboolean(L, stackID);
                [invocation setArgument:&value atIndex:index];
            } else {
                mln_lua_checknumber(L, stackID);
                char value = lua_tonumber(L, stackID);
                [invocation setArgument:&value atIndex:index];
            }
            break;
        }
        case MLNUI_OBJCType_uchar: {
            mln_lua_checknumber(L, stackID);
            unsigned char value = lua_tonumber(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_short: {
            mln_lua_checknumber(L, stackID);
            short value = lua_tonumber(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_ushort: {
            mln_lua_checknumber(L, stackID);
            unsigned short value = lua_tonumber(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_int: {
            mln_lua_checknumber(L, stackID);
            int value = lua_tonumber(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_uint: {
            mln_lua_checknumber(L, stackID);
            unsigned int value = lua_tonumber(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_long: {
            mln_lua_checknumber(L, stackID);
            long value = lua_tonumber(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_ulong: {
            mln_lua_checknumber(L, stackID);
            unsigned long value = lua_tonumber(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_llong: {
            mln_lua_checknumber(L, stackID);
            long long value = lua_tonumber(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_ullong: {
            mln_lua_checknumber(L, stackID);
            unsigned long long value = lua_tonumber(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_float: {
            mln_lua_checknumber(L, stackID);
            float value = lua_tonumber(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_double: {
            mln_lua_checknumber(L, stackID);
            double value = lua_tonumber(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_char_ptr: {
            mln_lua_checkstring(L, stackID);
            const char *value = lua_tostring(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_void_ptr: {
            const void *value = NULL;
            if (lua_islightuserdata(L, stackID)) {
                value = lua_topointer(L, stackID);
            } if (lua_isstring(L, stackID)) {
                value = (void *)lua_tostring(L, stackID);
            } else {
                mln_lua_checkudata(L, stackID);
                value = lua_touserdata(L, stackID);
            }
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_const_char_ptr: {
            const char *value = lua_tostring(L, stackID);
            [invocation setArgument:&value atIndex:index];
            break;
        }
        case MLNUI_OBJCType_rect: {
            if (lua_isuserdata(L, stackID) || lua_istable(L, stackID)) {
                CGRect rect = [MLNUI_LUA_CORE(L) toCGRect:stackID error:NULL];
                [invocation setArgument:&rect atIndex:index];
            }
            break;
        }
        case MLNUI_OBJCType_size: {
            if (lua_isuserdata(L, stackID) || lua_istable(L, stackID)) {
                CGSize size = [MLNUI_LUA_CORE(L) toCGSize:stackID error:NULL];
                [invocation setArgument:&size atIndex:index];
            }
            break;
        }
        case MLNUI_OBJCType_point: {
            if (lua_isuserdata(L, stackID) || lua_istable(L, stackID)) {
                CGPoint point = [MLNUI_LUA_CORE(L) toCGPoint:stackID error:NULL];
                [invocation setArgument:&point atIndex:index];
            }
            break;
        }
        default: {
            mln_lua_error(L, @"Undefined parameter type！");
            return NO; // 参数类型不支持
        }
    }
    return YES;
}

static MLNUI_FORCE_INLINE int __mln_lua_pushinvocation_return(NSInvocation* invocation, lua_State* L, BOOL needReturnSelf, BOOL isInit) {
    const char *type = [invocation.methodSignature methodReturnType];
    if (!charpNotEmpty(type)) {
        mln_lua_error(L, @"Undefined parameter type！");
        return 0;
    }
    switch (mln_objctype(type)) {
        case MLNUI_OBJCType_void:
            if (needReturnSelf) {
                lua_pushvalue(L, 1);
                return 1;
            }
            return 0;
        case MLNUI_OBJCType_BOOL: {
            BOOL result = 0;
            [invocation getReturnValue: &result];
            lua_pushboolean(L, result);
            return 1;
        }
        case MLNUI_OBJCType_class: {
            Class clazz = nil;
            [invocation getReturnValue:&clazz];
            if (clazz) {
                lua_pushstring(L, NSStringFromClass(clazz).UTF8String);
            } else {
                lua_pushnil(L);
            }
            return 1;
        }
        case MLNUI_OBJCType_SEL: {
            SEL sel = nil;
            [invocation getReturnValue:&sel];
            if (sel) {
                lua_pushstring(L, NSStringFromSelector(sel).UTF8String);
            } else {
                lua_pushnil(L);
            }
            return 1;
        }
        case MLNUI_OBJCType_id: {
            void *result = nil;
            [invocation getReturnValue:&result];
            NSObject * obj = (__bridge NSObject *)result;
            if (isInit) {
                // 标注为Lua创建
                obj.mln_isLuaObject = YES;
            }
            int nret = [MLNUI_LUA_CORE(L) pushNativeObject:obj error:NULL];
            if (isInit) {
                // 模拟ARC，手动添加release
                CFBridgingRelease(result);
            }
            return nret;
        }
        case MLNUI_OBJCType_char: {
            char result = 0;
            [invocation getReturnValue: &result];
            // @note iPhone 的32 bit 机器上，BOOL的签名和char是同一个。
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
            lua_pushnumber(L, result);
            return 1;
#else
            typedef long NSInteger;
            if (result == '\0') {
                lua_pushboolean(L, result);
                return 1;
            }
            lua_pushnumber(L, result);
            return 1;
#endif
        }
        case MLNUI_OBJCType_uchar: {
            unsigned char result = 0;
            [invocation getReturnValue: &result];
            lua_pushnumber(L, result);
            return 1;
        }
        case MLNUI_OBJCType_short: {
            short result = 0;
            [invocation getReturnValue: &result];
            lua_pushnumber(L, result);
            return 1;
        }
        case MLNUI_OBJCType_ushort: {
            unsigned short result = 0;
            [invocation getReturnValue: &result];
            lua_pushnumber(L, result);
            return 1;
        }
        case MLNUI_OBJCType_int: {
            int result = 0;
            [invocation getReturnValue: &result];
            lua_pushnumber(L, result);
            return 1;
        }
        case MLNUI_OBJCType_uint: {
            unsigned int result = 0;
            [invocation getReturnValue: &result];
            lua_pushnumber(L, result);
            return 1;
        }
        case MLNUI_OBJCType_long: {
            long result = 0;
            [invocation getReturnValue: &result];
            lua_pushnumber(L, result);
            return 1;
        }
        case MLNUI_OBJCType_ulong: {
            unsigned long result = 0;
            [invocation getReturnValue: &result];
            lua_pushnumber(L, result);
            return 1;
        }
        case MLNUI_OBJCType_llong: {
            long long result = 0;
            [invocation getReturnValue: &result];
            lua_pushnumber(L, result);
            return 1;
        }
        case MLNUI_OBJCType_ullong: {
            unsigned long long result = 0;
            [invocation getReturnValue: &result];
            lua_pushnumber(L, result);
            return 1;
        }
        case MLNUI_OBJCType_float: {
            float result = 0;
            [invocation getReturnValue: &result];
            lua_pushnumber(L, result);
            return 1;
        }
        case MLNUI_OBJCType_double: {
            double result = 0;
            [invocation getReturnValue: &result];
            lua_pushnumber(L, result);
            return 1;
        }
        case MLNUI_OBJCType_char_ptr: {
            char *result = 0;
            [invocation getReturnValue: &result];
            lua_pushlightuserdata(L, result);
            return 1;
        }
        case MLNUI_OBJCType_void_ptr: {
            void *result = 0;
            [invocation getReturnValue: &result];
            lua_pushlightuserdata(L, result);
            return 1;
        }
        case MLNUI_OBJCType_rect:{
            CGRect rect = CGRectZero;
            [invocation getReturnValue:&rect];
            return [MLNUI_LUA_CORE(L) pushCGRect:rect error:NULL];
        }
        case MLNUI_OBJCType_size:{
            CGSize size = CGSizeZero;
            [invocation getReturnValue:&size];
            return [MLNUI_LUA_CORE(L) pushCGSize:size error:NULL];
        }
        case MLNUI_OBJCType_point:{
            CGPoint point = CGPointZero;
            [invocation getReturnValue:&point];
            return [MLNUI_LUA_CORE(L) pushCGPoint:point error:NULL];
        }
        default: {
            mln_lua_error(L, @"Undefined parameter type！");
            return 0; // 参数类型不支持
        }
    }
    mln_lua_error(L, @"Undefined parameter type！");
    return 0;
}

static MLNUI_FORCE_INLINE int __mln_lua_objc_invoke (lua_State *L, int statrtStackIdx, id target, SEL selector, BOOL isclass, BOOL needReturnSelf, BOOL isInit) {
    NSString *s_clazz = NSStringFromClass(isclass ? target : [target class]);
    NSString *s_selector = NSStringFromSelector(selector);
    NSMethodSignature *sig = _mm_objc_method_signature(s_clazz, s_selector, target, selector);
    if (!sig) {
        NSString *targetMsg = s_clazz;
        NSString *selMsg = NSStringFromSelector(selector);
        NSString *errmsg = [NSString stringWithFormat:@"The method signature cannot be nil! \n taget : %@ \n selector : %@",targetMsg, selMsg];
        mln_lua_error(L, @"%@", errmsg);
        return 0;
    }
    // 当方法为init...初始化方法时，默认传递参数的个数为3，其他情况为2
    NSInteger startIdx = isInit ? 3 : 2;
    NSUInteger argsCount = [sig numberOfArguments] - startIdx;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    NSMutableArray *retainArray = [NSMutableArray arrayWithCapacity:argsCount];
    [invocation retainArguments];
    if (isInit) {
        // 默认传入LuaCore
        id luaCore = MLNUI_LUA_CORE(L);
        [invocation setArgument:&luaCore atIndex:2];
    }
    int stackIdx = statrtStackIdx;
    for (NSInteger i = startIdx; i < argsCount + startIdx; i++) {
        BOOL ret = __mln_lua_setinvocation(L, invocation, i, stackIdx, retainArray);
        if (!ret) {
            NSString *targetMsg = target ? (isclass ? NSStringFromClass(target) : target) : @"<nil>";
            NSString *selMsg = selector ? NSStringFromSelector(selector) : @"<nil>";
            NSString *errmsg = [NSString stringWithFormat:@"The method signature cannot be nil! \n taget : %@ \n selector : %@",targetMsg, selMsg];
            mln_lua_error(L, @"%@", errmsg);
            return 0;
        }
        stackIdx++;
    }
    [invocation invoke];
    return __mln_lua_pushinvocation_return(invocation, L, needReturnSelf, isInit);
}

#pragma mark - Public Functions

int mln_lua_constructor (lua_State *L) {
    mln_lua_assert(L, isMainQueue,  @"only be called in main thread!");
    // class
    Class clazz = __mln_lua_getclass(L);
    // selector
    SEL selector = __mln_lua_getselector(L);
    // target
    id target = [clazz alloc];
    if (!target) {
        NSString *targetMsg = NSStringFromClass(clazz);
        NSString *selMsg = selector ? NSStringFromSelector(selector) : @"<nil>";
        NSString *errmsg = [NSString stringWithFormat:@"The method signature cannot be nil! \n taget : %@ \n selector : %@",targetMsg, selMsg];
        mln_lua_assert(L, NO, @"%@", errmsg);
        return 0;
    }
    BOOL isInitSel = NO;
    if (selector) {
        NSString *selectorName = NSStringFromSelector(selector);
        if ([selectorName hasPrefix:@"init"]) {
            isInitSel = YES;
            // 模拟ARC，手动添加retain
            CFBridgingRetain(target);
        }
    }
    // call
    return __mln_lua_objc_invoke(L, 1, target, selector, NO, NO, isInitSel);
}

int mln_lua_obj_method (lua_State *L) {
    // selector
    BOOL isProperty = __mln_lua_isproperty(L);
    SEL selector = isProperty ? __mln_lua_getproperty_selector(L) : __mln_lua_getselector(L);
    // target
    id target = __mln_lua_getuserdata_target(L);
    // call
    return __mln_lua_objc_invoke(L, 2, target, selector, NO, YES, NO);
}

/**
 lua虚拟机调用OC类方法的路由函数
 
 @param L  虚拟机
 @return  OC类方法返回结果个数到lua虚拟机
 */
int mln_lua_class_method (lua_State *L)
{
    // class
    Class clazz = __mln_lua_getclass(L);
    // selector
    SEL selector = __mln_lua_getselector(L);
    // reset lua core
    [(Class<MLNUIStaticExportProtocol>)clazz mln_updateCurrentLuaCore:MLNUI_LUA_CORE(L)];
    // call
    return __mln_lua_objc_invoke(L, 2, clazz, selector, YES, YES, NO);
}

/**
 lua虚拟机全局函数调用OC类方法的路由函数
 
 @param L  虚拟机
 @return  OC类方法返回结果个数到lua虚拟机
 */
int mln_lua_global_func (lua_State *L)
{
    // class
    Class clazz = __mln_lua_getclass(L);
    // selector
    SEL selector = __mln_lua_getselector(L);
    // reset lua core
    [(Class<MLNUIStaticExportProtocol>)clazz mln_updateCurrentLuaCore:MLNUI_LUA_CORE(L)];
    // call
    return __mln_lua_objc_invoke(L, 1, clazz, selector, YES, NO, NO);
}
