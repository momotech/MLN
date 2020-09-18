//
//  MLNUIViewController+DataBinding.m
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/4/24.
//

#import "MLNUIViewController+DataBinding.h"
#import "MLNUIDataBinding.h"
#import "MLNUILuaCore.h"
#import "MLNUIKitInstance.h"
#import "MLNUIExtScope.h"
#import "MLNUIHeader.h"
#import "ArgoDataBinding.h"
#import "ArgoDataBindingProtocol.h"

@implementation MLNUIViewController (DataBinding)
- (UIView *)findViewById:(NSString *)identifier {
    lua_State *L = self.kitInstance.luaCore.state;
    int base = lua_gettop(L);
    lua_getglobal(L, "ui_views");
    if (!lua_istable(L, -1)) {
        lua_settop(L, base);
        return nil;
    }
    lua_pushstring(L, identifier.UTF8String);
    lua_rawget(L, -2);
    if (!lua_isuserdata(L, -1)) {
          lua_settop(L, base);
          return nil;
      }
    MLNUIUserData *ud = (MLNUIUserData *)lua_touserdata(L, -1);
    UIView *view = nil;
    if (ud) {
        view = (__bridge __unsafe_unretained UIView *)ud->object;
    }
    lua_settop(L, base);
    return view;
}

- (void)bindData:(NSObject *)data {
    [self.mlnui_dataBinding bindData:data];
}

- (void)bindData:(NSObject *)data forKey:(NSString *)key {
    [self.mlnui_dataBinding bindData:data forKey:key];
}

- (MLNUIDataBinding *)mlnui_dataBinding {
//    if (!_dataBinding) {
//# if OCPERF_USE_NEW_DB
//        _dataBinding = [[ArgoDataBinding alloc] init];
//#else
//        _dataBinding = [[MLNUIDataBinding alloc] init];
//#endif
//
//#if DEBUG
//        @weakify(self);
//        _dataBinding.errorLog = ^(NSString * _Nonnull log) {
//            @strongify(self);
//            MLNUIError(self.kitInstance.luaCore, @"%@",log);
//        };
//#endif
//    }
//    return _dataBinding;
    return [self argo_dataBinding];
}

# if OCPERF_USE_NEW_DB
- (void)addLifeCycleListener:(id)block {}
#endif

@end


@implementation UIViewController (MLNUIDataBinding)

- (MLNUIDataBinding *)mlnui_dataBinding {
//    MLNUIDataBinding *obj = objc_getAssociatedObject(self, _cmd);
//    if (!obj) {
////        obj = [[MLNUIDataBinding alloc] init];
//# if OCPERF_USE_NEW_DB
//        obj = [[ArgoDataBinding alloc] init];
//#else
//        obj = [[MLNUIDataBinding alloc] init];
//#endif
//        objc_setAssociatedObject(self, _cmd, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return obj;
    return [self argo_dataBinding];
}

- (void)mlnui_addToSuperViewController:(UIViewController *)superVC frame:(CGRect) frame {
    if (superVC) {
        [superVC addChildViewController:self];
        self.view.frame = frame;
        [superVC.view addSubview:self.view];
        [self didMoveToParentViewController:superVC];
    }
}
@end



///**
//通过id获取视图
//
//@param identifier 视图对应的id
//*/
//- (UIView *)findViewById:(NSString *)identifier;

/**
声明访问某个Lua的视图

@param LUA_VIEW_CONTROLLER  Lua所属的视图控制器
@param VIEW_ID 访问视图的ID
*/
#define MLNUI_VIEW_IMPORT(LUA_VIEW_CONTROLLER, VIEW_ID)\
- (UIView *)VIEW_ID\
{\
return [(LUA_VIEW_CONTROLLER) findViewById: @#VIEW_ID];\
}

/**
声明访问某个Lua的视图,并声明别名。之后Native可以通过别名访问

@param LUA_VIEW_CONTROLLER  Lua所属的视图控制器
@param VIEW_ID 访问视图的ID
@param VIEW_ALIAS 访问视图的别名
*/
#define MLNUI_VIEW_IMPORT_WITH_ALIAS(LUA_VIEW_CONTROLLER, VIEW_ID, VIEW_ALIAS)\
- (UIView *)VIEW_ALIAS\
{\
return [(LUA_VIEW_CONTROLLER) findViewById: @#VIEW_ID];\
}
