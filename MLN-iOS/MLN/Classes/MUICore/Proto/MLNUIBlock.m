//
//  MLNUIBlock.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNUIBlock.h"
#import "MLNUILuaCore.h"
#import "MLNUILuaTable.h"
#import "MLNUIHeader.h"
#import "MLNUIExtScope.h"
//#import "MLNUIKitHeader.h"
//#import "MLNUILazyBlockTask.h"

@interface MLNUIBlock ()

@property (nonatomic, strong) NSMutableArray *arguments;

@property (nonatomic, strong, readwrite) NSValue *innerFunction;
//@property (nonatomic, strong) MLNUILazyBlockTask *lazyTask;
//@property (nonatomic, strong) void(^completionBlock)(id);

@end

@implementation MLNUIBlock

static int mlnui_errorFunc_traceback (lua_State *L) {
    if(!lua_isstring(L,1))
        return 1;
    lua_getfield(L,LUA_GLOBALSINDEX,"debug");
    if(!lua_istable(L,-1)) {
        lua_pop(L,1);
        return 1;
    }
    lua_getfield(L,-1,"traceback");
    if(!lua_isfunction(L,-1)) {
        lua_pop(L,2);
        return 1;
    }
    lua_pushvalue(L,1);
    lua_pushinteger(L,2);
    lua_call(L,2,1);
    return 1;
}

#pragma mark - Initialization
- (instancetype)initWithMLNUILuaCore:(MLNUILuaCore *)luaCore indexOnLuaStack:(int)index
{
    if (self = [super init]) {
        _luaCore = luaCore;
        _arguments = [NSMutableArray array];
        [self retainLuaFunc:self.luaCore.state index:index];
    }
    return self;
}

#pragma mark - Save Lua Function
- (void)retainLuaFunc:(lua_State *)L index:(int)index
{
    MLNUIAssertMainThread();
    if (L == NULL) {
        MLNUIError(self.luaCore, @"Lua state is released");
        return;
    }
    lua_checkstack(L, 4); // [ ... ]
    lua_pushvalue(L, index);// [...| func (index)| ... | func ]
    lua_pushlightuserdata(L,(__bridge void *)self); // [...| func (index)| ... | func | self ]
    lua_insert(L, -2); // [...| func (index)| ... | self | func ]
    lua_settable(L, LUA_REGISTRYINDEX); // regist[self] = func
    self.innerFunction = [NSValue valueWithPointer:lua_topointer(L, index)];
}

#pragma mark - Call Lua Function
- (id)callWithParam:(id)aParam
{
    MLNUIAssertMainThread();
    [self addObjArgument:aParam];
    return [self callIfCan];
}

- (id)callIfCan
{
    NSArray *args = self.arguments.copy;
    [self reset];
    return [self callWithArguments:args];
}

- (id)callWithArguments:(NSArray *)arguments {
    MLNUIAssertMainThread();
    MLNUILuaCore *core = self.luaCore; //retain luaCore.
    lua_State *L = core.state;
    if (L == NULL) {
//        [self reset];
        return nil;
    }
    int base = lua_gettop(L);
    // 添加error处理函数
    lua_pushcfunction(L, mlnui_errorFunc_traceback);
    // Lua Fucntion 压栈
    lua_pushlightuserdata(L, (__bridge void *)self); // [ ... | table | self ]
    lua_gettable(L, LUA_REGISTRYINDEX); // ? = table[self] // [ ... | table | ? ]
    mlnui_luaui_checkfunc(L, -1);
    // 参数压栈
    int argsCount = (int)arguments.count;
    for (id arg in arguments) {
#if OCPERF_USE_NEW_DB
        if (![self.luaCore.convertor pushArgoBindingNativeObject:arg error:NULL]) {
#else
        if (![self.luaCore pushNativeObject:arg error:NULL]) {
#endif
            // 重置当前配置
//            [self reset];
            // 恢复栈
            lua_settop(L, base);
            return nil;
        }
    }
    // 重置当前配置
//    [self reset];
    // 调用
    int success = lua_pcall(L, argsCount, 1, base + 1);
    id result = nil;
    if (success == 0) {
        if (lua_gettop(L) > base) {
            result = [self.luaCore toNativeObject:-1 error:NULL];
        }
    } else {
        NSString *msg = [NSString stringWithUTF8String:lua_tostring(L, -1) ?: "null"];
        MLNUIError(MLNUI_LUA_CORE(L), @"fail to call lua function! error message: %@", msg);
    }
    // 恢复栈
    lua_settop(L, base);
    return result;
}

//- (void)lazyCallIfCan:(void(^)(id))completionBlock {
//    doInMainQueue
//    (
//#if OCPERF_COALESCE_BLOCK
//      @weakify(self);
//      NSArray *args = self.arguments.copy;
//      [self reset];
//      MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE(self.luaCore);
//      MLNUILazyBlockTask *task = [MLNUILazyBlockTask taskWithCallback:^{
//         @strongify(self);
//         if (!self) return;
//         id r = [self callWithArguments:args];
//         if (completionBlock) {
//             completionBlock(r);
//         }
//     } taskID:self.innerFunction];
//      [instance forcePushLazyTask:task];
//#else
//     [self callIfCan];
//#endif
//     )
//}

- (void)reset
{
    MLNUIAssertMainThread();
    [self.arguments removeAllObjects];
}

#pragma mark - Setup Parameters For Lua Function
- (void)addObjArgument:(id)argument
{
    MLNUIAssertMainThread();
    if (!argument) {
        argument = [NSNull null];
    }
    [self.arguments addObject:argument];
}

- (void)addIntArgument:(int)argument
{
    MLNUIAssertMainThread();
    [self.arguments addObject:@(argument)];
}

- (void)addFloatArgument:(float)argument
{
    MLNUIAssertMainThread();
    [self.arguments addObject:@(argument)];
}

- (void)addDoubleArgument:(double)argument
{
    MLNUIAssertMainThread();
    [self.arguments addObject:@(argument)];
}

- (void)addBOOLArgument:(BOOL)argument
{
    MLNUIAssertMainThread();
    [self.arguments addObject:@(argument)];
}

- (void)addIntegerArgument:(NSInteger)argument
{
    MLNUIAssertMainThread();
    [self.arguments addObject:@(argument)];
}

- (void)addUIntegerArgument:(NSUInteger)argument
{
    MLNUIAssertMainThread();
    [self.arguments addObject:@(argument)];
}

- (void)addCGRectArgument:(CGRect)argument
{
    MLNUIAssertMainThread();
    [self.arguments addObject:@(argument)];
}

- (void)addCGPointArgument:(CGPoint)argument
{
    MLNUIAssertMainThread();
    [self.arguments addObject:@(argument)];
}

- (void)addCGSizeArgument:(CGSize)argument
{
    MLNUIAssertMainThread();
    [self.arguments addObject:@(argument)];
}

- (void)addStringArgument:(NSString *)argument
{
    MLNUIAssertMainThread();
    if (!argument) {
        [self.arguments addObject:[NSNull null]];
        return;
    }
    [self.arguments addObject:argument];
}

- (void)addMapArgument:(NSDictionary *)argument
{
    MLNUIAssertMainThread();
    if (!argument) {
        [self.arguments addObject:[NSNull null]];
        return;
    }
    if ([argument mlnui_nativeType] != MLNUINativeTypeMDictionary) {
        argument = [NSMutableDictionary dictionaryWithDictionary:argument];
    }
    [self.arguments addObject:argument];
}

- (void)addArrayArgument:(NSArray *)argument
{
    MLNUIAssertMainThread();
    if (!argument) {
        [self.arguments addObject:[NSNull null]];
        return;
    }
    if ([argument mlnui_nativeType] != MLNUINativeTypeMArray) {
        argument = [NSMutableArray arrayWithArray:argument];
    }
    [self.arguments addObject:argument];
}

- (void)addLuaTableArgumentWithArray:(NSArray *)argument
{
    MLNUIAssertMainThread();
    if (!argument) {
        [self.arguments addObject:[NSNull null]];
        return;
    }
    [self.arguments addObject:argument];
}

- (void)addLuaTableArgumentWithDictionary:(NSDictionary *)argument
{
    MLNUIAssertMainThread();
    if (!argument) {
        [self.arguments addObject:[NSNull null]];
        return;
    }
    [self.arguments addObject:argument];
}

- (void)addLuaTableArgument:(MLNUILuaTable *)argument;
{
    MLNUIAssertMainThread();
    if (!argument) {
        [self.arguments addObject:[NSNull null]];
        return;
    }
    [self.arguments addObject:argument];
}

static void releaseAllInMainQueue (MLNUILuaCore *luaCore, void * selfp) {
    if (isMainQueue) {
        lua_State *L = luaCore.state;
        if (L) {
            lua_checkstack(L, 4);
            lua_pushlightuserdata(L, selfp);
            lua_pushnil(L);
            lua_settable(L, LUA_REGISTRYINDEX);
        }
    } else {
        __weak typeof(luaCore) wLuaCore = luaCore;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wLuaCore) sLuaCore = wLuaCore;
            lua_State *L = sLuaCore.state;
            if (L) {
                lua_checkstack(L, 4);
                lua_pushlightuserdata(L, selfp);
                lua_pushnil(L);
                lua_settable(L, LUA_REGISTRYINDEX);
            }
        });
    }
}

//- (MLNUILazyBlockTask *)lazyTask {
//    if (!_lazyTask) {
//        @weakify(self);
//        _lazyTask = [MLNUILazyBlockTask taskWithCallback:^{
//            @strongify(self);
//            id r = [self callIfCan];
//            if (self.completionBlock) {
//                self.completionBlock(r);
//            }
//        } taskID:self.innerFunction];
//    }
//    return _lazyTask;
//}

#pragma mark - Remove Lua Function
- (void)dealloc
{
    releaseAllInMainQueue(self.luaCore, (__bridge void *)self);
}

@end
