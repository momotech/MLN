//
//  MLNUICore.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "MLNUILuaCore.h"
#import "NSError+MLNUICore.h"
#import "MLNUILuaBundle.h"
#import "MLNUIExporterManager.h"
#import "MLNUIConvertor.h"
#import "MLNUIFileLoader.h"
#import "MLNUILuaTable.h"
#import "argo_lib.h"
#import "MLNUIExtScope.h"

@import ObjectiveC;

static void * mlnui_state_alloc(void *ud, void *ptr, size_t osize, size_t nsize) {
    (void)ud;
    (void)osize;
    if (nsize == 0) {
        free(ptr);
        return NULL;
    } else {
        return realloc(ptr, nsize);
    }
}

static MLNUI_FORCE_INLINE int mlnui_libsize (const struct mlnui_objc_method *list) {
    int size = 0;
    for (; list->l_mn; list++) size++;
    return size;
}

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

@interface MLNUILuaCore ()

@property (nonatomic, assign, getter=isCollecting) BOOL collecting;

@end

@implementation MLNUILuaCore (Stack)

- (int)pushNativeObject:(id)obj error:(NSError **)error
{
    return [self.convertor pushNativeObject:obj error:error];
}

- (BOOL)pushLuaTable:(id)collection error:(NSError **)error
{
    return [self.convertor pushLuaTable:collection error:error];
}

- (BOOL)pushString:(NSString *)aStr error:(NSError **)error
{
    return [self.convertor pushString:aStr error:error];
}

- (int)pushValua:(NSValue *)value error:(NSError * _Nullable __autoreleasing *)error
{
    return [self.convertor pushValua:value error:error];
}

- (int)pushCGRect:(CGRect)rect error:(NSError **)error
{
    return [self.convertor pushCGRect:rect error:error];
}

- (int)pushCGPoint:(CGPoint)point error:(NSError **)error
{
    return [self.convertor pushCGPoint:point error:error];
}

- (int)pushCGSize:(CGSize)size error:(NSError **)error
{
    return [self.convertor pushCGSize:size error:error];
}

- (id)toNativeObject:(int)idx error:(NSError * _Nullable __autoreleasing *)error
{
    return [self.convertor toNativeObject:idx error:error];
}

- (NSString *)toString:(int)idx error:(NSError **)error
{
    return [self.convertor toString:idx error:error];
}

- (CGRect)toCGRect:(int)idx error:(NSError **)error
{
    return [self.convertor toCGRect:idx error:error];
}

- (CGPoint)toCGPoint:(int)idx error:(NSError **)error
{
    return [self.convertor toCGPoint:idx error:error];
}

- (CGSize)toCGSize:(int)idx error:(NSError **)error
{
    return [self.convertor toCGSize:idx error:error];
}

@end

@implementation MLNUILuaCore (GC)

- (void)doGC
{
    if (!self.isCollecting) {
        self.collecting = YES;
        lua_State *state = self.state;
        if (state) {
            lua_gc(state, LUA_GCCOLLECT, 0);
        }
        self.collecting = NO;
    }
}

- (void)mlnui_addMemoryWarningNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mlnui_didReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

- (void)mlnui_removeMemoryWarningNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}


- (void)mlnui_didReceiveMemoryWarning:(NSNotification *)notification
{
    [self doGC];
}

@end

@implementation MLNUILuaCore (Traceback)

- (NSString *)traceback
{
    lua_State *L = self.state;
    if (L) {
        int base = lua_gettop(L);
         lua_getglobal(L, "debug");
         if(!lua_istable(L,-1)) {
             lua_settop(L, base);
             return @"\ntraceback not found!";
         }
         lua_getfield(L,-1,"traceback");
         if(!lua_isfunction(L,-1)) {
             lua_settop(L, base);
             return @"\ntraceback not found!";
         }
        int iError = lua_pcall(L, 0, 1, 0);
        if (!lua_isstring(L, -1)) {
            lua_settop(L, base);
            return @"\ntraceback not found!";
        }
        NSString *msg = nil;
        const char *s = lua_tostring(L, -1);
        if (s) {
            msg = [NSString stringWithFormat:@"\nError Code For Traceback: %d \n %s", iError, lua_tostring(L, -1)];
        }
        lua_settop(L, base);
        return msg;
    }
    return @"\nThe lua state is released";
}

- (int)tracebackCount
{
    lua_State *L = self.state;
    if (L) {
        lua_Debug ar;
        int index = 1;
        while (lua_getstack(L, index, &ar))
            index++;
        return index - 1;
    }
    return 0;
}

@end

@implementation MLNUILuaCore

- (instancetype)initWithLuaBundlePath:(NSString *)luaBundlePath
{
    return [self initWithLuaBundle:[MLNUILuaBundle bundleCachesWithPath:luaBundlePath] convertor:nil exporter:nil];
}

- (instancetype)initWithLuaBundle:(MLNUILuaBundle *)bundle
{
    return [self initWithLuaBundle:bundle convertor:nil exporter:nil];
}

- (instancetype)initWithLuaBundle:(MLNUILuaBundle *__nullable)luaBundle convertor:(Class<MLNUIConvertorProtocol> __nullable)convertorClass exporter:(Class<MLNUIExporterProtocol> __nullable)exporterClass
{
    if (self = [super init]) {
        [self openLuaStateIfNeed];
        [self addNotification];
        if (!exporterClass) {
            exporterClass = [MLNUIExporterManager class];
        }
        _exporter = [[(Class)exporterClass alloc] initWithMLNUILuaCore:self];
        if (!convertorClass) {
            convertorClass = [MLNUIConvertor class];
        }
        _convertor = [[(Class)convertorClass alloc] initWithMLNUILuaCore:self];
        _currentBundle = luaBundle;
        if (!_currentBundle) {
            _currentBundle = [MLNUILuaBundle mainBundle];
        }
        [self createViewStrongTable];
        [self registerMLNUIBridge];
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithLuaBundle:[MLNUILuaBundle mainBundle] convertor:nil exporter:nil];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)createViewStrongTable
{
    _objStrongTable = [[MLNUILuaTable alloc] initWithMLNUILuaCore:self env:MLNUILuaTableEnvRegister];
}

- (BOOL)runFile:(NSString *)filePath error:(NSError * _Nullable __autoreleasing *)error
{
    BOOL ret = [self loadFile:filePath error:error];
    if (!ret) {
        return ret;
    }
    
    PSTART(MLNUILoadTimeStatisticsType_Execute);
    BOOL r = [self call:0 error:error];
    PEND(MLNUILoadTimeStatisticsType_Execute);
    return r;
}

- (BOOL)runData:(NSData *)data name:(NSString *)name error:(NSError * _Nullable __autoreleasing *)error
{
    BOOL ret = [self loadData:data name:name error:error];
    if (!ret) {
        return ret;
    }
    PSTART(MLNUILoadTimeStatisticsType_Execute);
    BOOL r = [self call:0 error:error];
    PEND(MLNUILoadTimeStatisticsType_Execute);
    return r;
}

- (BOOL)loadFile:(NSString *)filePath error:(NSError * _Nullable __autoreleasing *)error
{
    _filePath = filePath;
    PSTART_TAG(MLNUILoadTimeStatisticsType_ReadFile, filePath);
    NSString *realFilePath = [self.currentBundle filePathWithName:filePath];
    NSData *data = [NSData dataWithContentsOfFile:realFilePath];
    PEND_TAG_INFO(MLNUILoadTimeStatisticsType_ReadFile, filePath, filePath);
    
    PSTART_TAG(MLNUILoadTimeStatisticsType_Compile,filePath);
    BOOL r = [self loadData:data name:filePath error:error];
    PEND_TAG_INFO(MLNUILoadTimeStatisticsType_Compile, filePath, filePath);
    
    return r;
}

- (BOOL)loadData:(NSData *)data name:(NSString *)name error:(NSError **)error
{
    // 回调代理
    if ([self.delegate respondsToSelector:@selector(luaCore:willLoad:filePath:)]) {
        [self.delegate luaCore:self willLoad:data filePath:name];
    }
    if (!data || data.length <=0) {
        NSString *errmsg = [NSString stringWithFormat:@"%@ not found", name];
        NSError *err = [NSError mlnui_errorLoad:errmsg];
        if (error) {
            *error = err;
        }
        MLNUIError(self, @"%@ not found", name);
        // 回调代理
        if ([self.delegate respondsToSelector:@selector(luaCore:didFailLoad:filePath:error:)]) {
            [self.delegate luaCore:self didFailLoad:data filePath:name error:err];
        }
        return NO;
    }
    if (!stringNotEmpty(name)) {
        NSString *errmsg = [NSString stringWithFormat:@"%@ not found", name];
        NSError *err = [NSError mlnui_errorLoad:errmsg];
        if (error) {
            *error = err;
        }
        MLNUIError(self, @"%@ not found", name);
        // 回调代理
        if ([self.delegate respondsToSelector:@selector(luaCore:didFailLoad:filePath:error:)]) {
            [self.delegate luaCore:self didFailLoad:data filePath:name error:err];
        }
        return NO;
    }
    _filePath = name;
    lua_State *L = self.state;
    if (!L) {
        NSError *err = [NSError mlnui_errorState:@"Lua state is released"];
        if (error) {
            *error = err;
        }
        MLNUIError(self, @"Lua state is released");
        // 回调代理
        if ([self.delegate respondsToSelector:@selector(luaCore:didFailLoad:filePath:error:)]) {
            [self.delegate luaCore:self didFailLoad:data filePath:name error:err];
        }
        return NO;
    }
    int code = luaL_loadbuffer(L, data.bytes, data.length, name.UTF8String);
    if (code != 0) {
        NSString *errMsg = [NSString stringWithFormat:@"%s", lua_tostring(L, -1)];
        NSError *err = [NSError mlnui_errorLoad:errMsg];
        if (error) {
            *error = err;
        }
        MLNUIError(self, @"%@", errMsg);
        // 回调代理
        if ([self.delegate respondsToSelector:@selector(luaCore:didFailLoad:filePath:error:)]) {
            [self.delegate luaCore:self didFailLoad:data filePath:name error:err];
        }
        return NO;
    }
    // 回调代理
    if ([self.delegate respondsToSelector:@selector(luaCore:didLoad:filePath:)]) {
        [self.delegate luaCore:self didLoad:data filePath:name];
    }
    return YES;
}

- (BOOL)call:(int)argCount error:(NSError *__autoreleasing  _Nullable *)error {
    return [self call:argCount retCount:0 error:error];
}

- (BOOL)call:(int)argCount retCount:(int)retCount error:(NSError *__autoreleasing  _Nullable *)error {
    lua_State *L = self.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self, @"Lua state is released");
        }
        return NO;
    }
    if (lua_type(L, -1) != LUA_TFUNCTION) {
        if (error) {
            *error = [NSError mlnui_errorCall:@"Function not found"];
            MLNUIError(self, @"Function not found");
        }
        return NO;
    }
    if(argCount > 0){
        lua_insert(L, -argCount - 1);
    }
    int base = lua_gettop(L) - argCount;  /* function index */
    lua_pushcfunction(L, mlnui_errorFunc_traceback);  /* push traceback function */
    lua_insert(L, base);  /* put it under chunk and args */
    int code = lua_pcall(L, argCount, retCount, base);
    if (code != 0) {
        NSString *errmsg = [NSString stringWithFormat:@"%s", lua_tostring(L, -1)];
        if (error) {
            *error = [NSError mlnui_errorCall:errmsg];
            MLNUIError(self, @"%s", lua_tostring(L, -1));
        }
        return NO;
    }
    return YES;
}

- (BOOL)openCLib:(const char *)libName methodList:(const luaL_Reg *)list nup:(int)nup error:(NSError * _Nullable __autoreleasing *)error
{
    lua_State *L = self.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self, @"Lua state is released");
        }
        return NO;
    }
    luaL_openlib(L, libName, list, nup);
    return YES;
}

- (BOOL)openLib:(const char *)libName nativeClassName:(const char *)nativeClassName methodList:(const struct mlnui_objc_method *)list nup:(int)nup leaveTableOnTop:(BOOL)leaveTable error:(NSError **)error
{
    lua_State *L = self.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self, @"Lua state is released");
        }
        return NO;
    }
    if (libName) {
        int size = mlnui_libsize(list);
        /* check whether lib already exists */
        luaL_findtable(L, LUA_REGISTRYINDEX, "_LOADED", 1);
        lua_getfield(L, -1, libName);  /* get _LOADED[libname] */
        if (!lua_istable(L, -1)) {  /* not found? */
            lua_pop(L, 1);  /* remove previous result */
            /* try global variable (and create one if it does not exist) */
            if (luaL_findtable(L, LUA_GLOBALSINDEX, libName, size) != NULL)
                luaL_error(L, "name conflict for module " LUA_QS, libName);
            lua_pushvalue(L, -1);
            lua_setfield(L, -3, libName);  /* _LOADED[libname] = new table */
        }
        lua_remove(L, -2);  /* remove _LOADED table */
        lua_insert(L, -(nup+1));  /* move library table to below upvalues */
    }
    BOOL shouldPOP = !leaveTable;
    @onExit{
        if (shouldPOP) {
            lua_pop(L, 1);
        }
    };

    for (; list->l_mn; list++) {
        if (!charpNotEmpty(list->clz)) {
            if (error) {
                *error = [NSError mlnui_errorOpenLib:@"The class name must not be nil!"];
                mlnui_luaui_error(L, @"The class name must not be nil!");
            }
            return NO;
        }
        if (list->func == NULL) {
            if (error) {
                *error = [NSError mlnui_errorOpenLib:@"The C function must not be NULL!"];
                mlnui_luaui_error(L, @"The C function must not be NULL!");
            }
            return NO;
        }
        int extraCount = 0;
#if OCPERF_USE_LUD
        Class cls = objc_getClass(nativeClassName);
        lua_pushlightuserdata(L, (__bridge void *)(cls));
#else
        lua_pushstring(L, nativeClassName); // class
#endif
        lua_pushboolean(L, list->isProperty);
        if (list->isProperty) {

#if OCPERF_USE_LUD
            SEL setter = sel_registerName(list->setter_n);
            SEL getter = sel_registerName(list->getter_n);
            lua_pushlightuserdata(L, setter);
            lua_pushlightuserdata(L, getter);
#else
            lua_pushstring(L, list->setter_n); // setter
            lua_pushstring(L, list->getter_n); // getter
#endif
            extraCount = 4;
        } else {
#if OCPERF_USE_LUD
            SEL sel = sel_registerName(list->mn);
            lua_pushlightuserdata(L, sel);
#else
            lua_pushstring(L, list->mn); // selector
#endif

            extraCount = 3;
        }
        int i;
        for (i=0; i<nup; i++)  /* copy upvalues to the top */
            lua_pushvalue(L, -(nup+extraCount));
        lua_pushcclosure(L, list->func, (nup+extraCount));
        lua_setfield(L, -(nup+2), list->l_mn);
    }
    lua_pop(L, nup);  /* remove upvalues */
    return YES;
}

- (BOOL)registerClazz:(Class<MLNUIExportProtocol>)clazz error:(NSError **)error
{
    NSParameterAssert(clazz);
    return [self.exporter exportClass:clazz error:error];
}

- (BOOL)registerClasses:(NSArray<Class<MLNUIExportProtocol>> *)classes error:(NSError **)error
{
    NSParameterAssert(classes && classes.count >0);
    NSArray<Class<MLNUIExportProtocol>> *classesCopy = classes.copy;
    for (Class<MLNUIExportProtocol> clazz in classesCopy) {
        BOOL ret = [self.exporter exportClass:clazz error:error];
        if (!ret) {
            MLNUIError(self, @"%@", error ? *error : [NSString stringWithFormat:@"%@ 注册失败",clazz]);
            return NO;
        }
    }
    return YES;
}

- (BOOL)registerGlobalFunc:(mln_lua_CFunction)cfunc name:(const char *)name error:(NSError * _Nullable __autoreleasing *)error
{
    return [self registerGlobalFunc:cfunc name:name nup:0 error:error];
}

- (BOOL)registerGlobalFunc:(mln_lua_CFunction)cfunc name:(const char *)name nup:(int)nup error:(NSError * _Nullable __autoreleasing *)error
{
    NSParameterAssert(charpNotEmpty(name));
    lua_State *L = self.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
        }
        return NO;
    }
    lua_checkstack(L, 12);
    lua_pushcclosure(L, cfunc, nup);
    lua_setglobal(L, name);
    return YES;
}

- (BOOL)registerGlobalFunc:(const char *)packageName libname:(const char *)libname methodList:(const struct mlnui_objc_method *)list nup:(int)nup error:(NSError **)error
{
    NSParameterAssert(charpNotEmpty(packageName));
    NSParameterAssert(charpNotEmpty(libname));
    lua_State *L = self.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
        }
        return NO;
    }
    BOOL needSetGlobal = YES;
    if (strcmp(packageName, "NULL") != 0) {
        lua_getglobal(L, packageName);
        if (!lua_istable(L, -1)) {
            lua_newtable(L);
            lua_pushvalue(L, -1);
            lua_setglobal(L, libname);
        }
    }
    if (strcmp(packageName, "NULL") != 0) {
        needSetGlobal = NO;
        if (!lua_istable(L, -1)) {
            lua_getglobal(L, libname);
            if (!lua_istable(L, -1)) {
                lua_newtable(L);
                lua_pushvalue(L, -1);
                lua_setglobal(L, libname);
            }
        } else {
            lua_getfield(L, 1, libname);
            if (!lua_istable(L, -1)) {
                lua_newtable(L);
                lua_pushstring(L, libname);
                lua_pushvalue(L, -2);
                lua_settable(L, -4);
            }
            lua_remove(L, -2);
        }
    }
    
    for (; list->l_mn; list++) {
        if (!charpNotEmpty(list->clz)) {
            if (error) {
                *error = [NSError mlnui_errorOpenLib:@"The class name must not be nil!"];
                mlnui_luaui_error(L, @"The class name must not be nil!");
            }
            return NO;
        }
        if (list->func == NULL) {
            if (error) {
                *error = [NSError mlnui_errorOpenLib:@"The C function must not be NULL!"];
                mlnui_luaui_error(L, @"The C function must not be NULL!");
            }
            return NO;
        }
        int extraCount = 0;
        lua_pushstring(L, list->clz); // class
        lua_pushboolean(L, list->isProperty);
        if (list->isProperty) {
            lua_pushstring(L, list->setter_n); // setter
            lua_pushstring(L, list->getter_n); // getter
            extraCount = 4;
        } else {
            lua_pushstring(L, list->mn); // selector
            extraCount = 3;
        }
        int i;
        for (i=0; i<nup; i++)  /* copy upvalues to the top */
            lua_pushvalue(L, -(nup+extraCount));
        lua_checkstack(L, 12);
        if (needSetGlobal) {
            lua_pushcclosure(L, list->func, (nup+extraCount));
            lua_setglobal(L, list->l_mn);
        } else {
            lua_pushcclosure(L, list->func, (nup+extraCount));
            if (strlen(list->l_mn) == 1) {
                int number = atoi(list->l_mn);
                lua_pushnumber(L, number);
            } else {
                lua_pushstring(L, list->mn);
            }
            lua_insert(L, -2);
            lua_settable(L, -3);
            lua_remove(L, -1);
        }
    }
    lua_pop(L, nup);  /* remove upvalues */
    return YES;
}

- (void)dumpstack:(lua_State *)L {
    int top=lua_gettop(L);
    for (int i=1; i <= top; i++) {
      printf("%d\t%s\t", i, luaL_typename(L,i));
      switch (lua_type(L, i)) {
        case LUA_TNUMBER:
          printf("%g\n",lua_tonumber(L,i));
          break;
        case LUA_TSTRING:
          printf("%s\n",lua_tostring(L,i));
          break;
        case LUA_TBOOLEAN:
          printf("%s\n", (lua_toboolean(L, i) ? "true" : "false"));
          break;
        case LUA_TNIL:
          printf("%s\n", "nil");
          break;
        default:
          printf("%p\n",lua_topointer(L,i));
          break;
      }
    }
}

NS_INLINE BOOL utils_string_is_number(const char *input) {
    if (!input) return NO;
    size_t len = strlen(input);
    if (len == 0) return NO;
        
    BOOL is_number = YES;
    for( size_t i = 0; i < len - 1; i++){
        if(!isdigit(input[i])){
            is_number = NO;
            break;
        }
    }
    return is_number;
}

- (BOOL)registerStaticFunc:(const char *)packageName libname:(const char *)libname methodList:(const struct mlnui_objc_method *)list nup:(int)nup error:(NSError **)error
{
    NSParameterAssert(charpNotEmpty(packageName));
    NSParameterAssert(charpNotEmpty(libname));
    lua_State *L = self.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
        }
        return NO;
    }
    
    BOOL needSetGlobal = YES;
    BOOL packageIsNull = strcmp(packageName, "NULL") == 0;
    BOOL libnameIsNull = strcmp(libname, "NULL") == 0;
    // libname as packageName
    if (packageIsNull && !libnameIsNull) {
        packageName = libname;
        packageIsNull = NO;
        libnameIsNull = YES;
    }
    
    if (!packageIsNull) {
        needSetGlobal = NO;
        lua_getglobal(L, packageName);
        if (!lua_istable(L, -1)) {
            lua_pop(L,1);
            lua_newtable(L);
            lua_pushvalue(L, -1);
            lua_setglobal(L, packageName);
        }
    }
    
    if (!libnameIsNull) {
        if (!lua_istable(L, -1)) { //not talbe, maybe create table failed in the previous step.
            mlnui_luaui_error(L, @"create table failed");
            lua_pop(L, 1);
            needSetGlobal = YES;
        } else {
            lua_getfield(L, -1, libname);
            if (!lua_istable(L, -1)) {
                lua_pop(L, 1);
                lua_newtable(L);
                lua_pushstring(L, libname);
                lua_pushvalue(L, -2);
                lua_settable(L, -4);
            }
            lua_remove(L, -2); // remove the table which created in the previous step.
        }
    }
    
    for (; list->l_mn; list++) {
        if (list->func == NULL) {
            if (error) {
                *error = [NSError mlnui_errorOpenLib:@"The C function must not be NULL!"];
                mlnui_luaui_error(L, @"The C function must not be NULL!");
            }
            return NO;
        }
        int extraCount = 0;
        for (int i = 0; i < nup; i++)  /* copy upvalues to the top */
            lua_pushvalue(L, -(nup + extraCount));
        
        lua_checkstack(L, 12);
                
        if (needSetGlobal) {
            lua_pushcclosure(L, list->func, (nup + extraCount));
            lua_setglobal(L, list->l_mn);
        } else {
            if (strlen(list->l_mn) == 1 && utils_string_is_number(list->l_mn)) {
                int number = atoi(list->l_mn);
                lua_pushnumber(L, number);
            } else {
                lua_pushstring(L, list->l_mn);
            }
            
            lua_pushcclosure(L, list->func, (nup + extraCount));
            lua_settable(L, -3);
        }
    }
    
    if (!needSetGlobal) {
        lua_remove(L, -1); /* remove package or libname table */
    }
    lua_pop(L, nup);  /* remove upvalues */
    return YES;
}

- (BOOL)registerGlobalVar:(id)value globalName:(NSString *)globalName error:(NSError * _Nullable __autoreleasing *)error
{
    NSParameterAssert(value);
    NSParameterAssert(globalName && globalName.length > 0);
    lua_State *L = self.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self, @"Lua state is released");
        }
        return NO;
    }
    lua_checkstack(L, 12);
    [self pushNativeObject:value error:error];
    lua_setglobal(L, globalName.UTF8String);
    return YES;
}

- (BOOL)requireLuaFile:(const char *)lua_file {
    NSParameterAssert(lua_file);
    if(!lua_file) return NO;
    lua_State *L = self.state;
    if (!L) {
        MLNUIError(self, @"Lua state is released %s",__func__);
        return NO;
    }
    int base = lua_gettop(L);
    
    lua_getglobal(L, "require");
    lua_pushstring(L, lua_file);
    int s = lua_pcall(L, 1, 0, 0);
    if (s && !lua_isnil(L, -1)) {
        const char *msg = lua_tostring(L, -1);
        if (msg == NULL)
            msg = "(error object is not a string)";
        MLNUIError(self, @"%s %s",msg, __func__);
    }
    
    if (s) {
        lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
        lua_pushnil(L);
        lua_setfield(L, -2, lua_file);
        lua_settop(L, base);
//        lua_gc(L, LUA_GCCOLLECT, 0);
    }
    return YES;;
}

- (BOOL)createMetaTable:(const char *)name error:(NSError * _Nullable __autoreleasing *)error
{
    NSParameterAssert(charpNotEmpty(name));
    lua_State *L = self.state;
    if (!L) {
        if (error) {
            *error = [NSError mlnui_errorState:@"Lua state is released"];
            MLNUIError(self, @"Lua state is released");
        }
        return NO;
    }
    
    if (luaL_newmetatable(L, name )) { // 0 == exist
        lua_pushvalue(L, -1);
        lua_setfield(L, -2, "__index");
    }
//    lua_pop(L, 1);
    return YES;
}

- (void)changeLuaBundleWithPath:(NSString *)bundlePath
{
    _currentBundle = [[MLNUILuaBundle alloc] initWithBundlePath:bundlePath];
}

- (void)changeLuaBundle:(MLNUILuaBundle *)bundle
{
    _currentBundle = bundle;
}

- (void)setStrongObjectWithIndex:(int)objIndex key:(NSString *)key
{
    [self.objStrongTable setObjectWithIndex:objIndex key:key];
}

- (void)setStrongObjectWithIndex:(int)objIndex cKey:(void *)cKey
{
    [self.objStrongTable setObjectWithIndex:objIndex cKey:cKey];
}

- (void)setStrongObject:(id<MLNUIEntityExportProtocol>)obj key:(NSString *)key
{
    [self.objStrongTable setObject:obj key:key];
}

- (void)setStrongObject:(id<MLNUIEntityExportProtocol>)obj cKey:(void *)cKey
{
    [self.objStrongTable setObject:obj cKey:cKey];
}

- (void)removeStrongObject:(NSString *)key
{
    [self.objStrongTable removeObject:key];
}

- (void)removeStrongObjectForCKey:(void *)cKey
{
    [self.objStrongTable removeObjectForCKey:cKey];
}

- (BOOL)pushStrongObject:(NSString *)key
{
    return [self.objStrongTable pushObjectToLuaStack:key] != NSNotFound;
}

- (BOOL)pushStrongObjectForCKey:(void *)cKey
{
    return [self.objStrongTable pushObjectToLuaStackForCKey:cKey] != NSNotFound;
}

#pragma mark - 私有方法
- (void)openLuaStateIfNeed
{
    if (!_state) {
        _state =  lua_newstate(mlnui_state_alloc, (__bridge void *)(self));
        luaL_openlibs(_state);
    }
}

- (void)registerMLNUIBridge
{
    NSArray *classes = @[[MLNUIFileLoader class]];
    [self registerClasses:classes error:NULL];
    [self openLuaDataBinding];
}

- (BOOL)openLuaDataBinding {
    lua_State *L = self.state;
    if (!L) {
        NSLog(@"Lua state is released");
        return NO;
    }
    argo_preload(L);
    return YES;
}

- (void)closeLuaDataBinding {
    lua_State *L = self.state;
    if (L) {
        argo_close(L);
    }
}

- (void)addNotification
{
    [self mlnui_addMemoryWarningNotification];
}

- (void)dealloc
{
    [self closeLuaDataBinding];
    [self mlnui_removeMemoryWarningNotification];
    [self releaseLuaCore];
}

- (void)releaseLuaCore
{
    lua_State *l = self.state;
    if (l) {
        _state = NULL;
        doInMainQueue(lua_close(l));
    }
}

#if DEBUG
static void dumpstack (lua_State *L) {
  int top=lua_gettop(L);
    printf("top is %d \n",top);
    
  for (int i=1; i <= top; i++) {
    printf("%d\t%s\t", i, luaL_typename(L,i));
    switch (lua_type(L, i)) {
      case LUA_TNUMBER:
        printf("%g\n",lua_tonumber(L,i));
        break;
      case LUA_TSTRING:
        printf("%s\n",lua_tostring(L,i));
        break;
      case LUA_TBOOLEAN:
        printf("%s\n", (lua_toboolean(L, i) ? "true" : "false"));
        break;
      case LUA_TNIL:
        printf("%s\n", "nil");
        break;
      default:
        printf("%p\n",lua_topointer(L,i));
        break;
    }
  }
}

- (void)printDebugStack {
    dumpstack(self.state);
}
#endif
@end
