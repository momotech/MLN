//
//  MLNKitViewController+DataBinding.m
// MLN
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNKitViewController+DataBinding.h"
#import "MLNDataBinding.h"
#import "MLNLuaCore.h"
#import "MLNKitInstance.h"

@implementation MLNKitViewController (DataBinding)

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
    MLNUserData *ud = (MLNUserData *)lua_touserdata(L, -1);
    UIView *view = nil;
    if (ud) {
        view = (__bridge __unsafe_unretained UIView *)ud->object;
    }
    lua_settop(L, base);
    return view;
}

- (void)bindData:(NSObject *)data forKey:(NSString *)key {
    [self.mln_dataBinding bindData:data forKey:key];
}

//- (void)updateDataForKeyPath:(NSString *)keyPath value:(id)value {
//    [self.mln_dataBinding updateDataForKeyPath:keyPath value:value];
//}
//
//- (id __nullable)dataForKeyPath:(NSString *)keyPath {
//    return [self.mln_dataBinding dataForKeyPath:keyPath];
//}
//
//- (void)addDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath {
//    [self.mln_dataBinding addDataObserver:observer forKeyPath:keyPath];
//}
//
//- (void)removeDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath {
//    [self.mln_dataBinding removeDataObserver:observer forKeyPath:keyPath];
//}

- (MLNDataBinding *)mln_dataBinding {
    if (!_dataBinding) {
        _dataBinding = [[MLNDataBinding alloc] init];
    }
    return _dataBinding;
}

@end


@implementation UIViewController (MLNDataBinding)

//- (MLNDataBinding *)mln_dataBinding {
//    MLNDataBinding *obj = objc_getAssociatedObject(self, _cmd);
//    if (!obj) {
//        obj = [[MLNDataBinding alloc] init];
//        objc_setAssociatedObject(self, _cmd, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return obj;
//}

- (void)mln_addToSuperViewController:(UIViewController *)superVC frame:(CGRect) frame {
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
#define MLN_VIEW_IMPORT(LUA_VIEW_CONTROLLER, VIEW_ID)\
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
#define MLN_VIEW_IMPORT_WITH_ALIAS(LUA_VIEW_CONTROLLER, VIEW_ID, VIEW_ALIAS)\
- (UIView *)VIEW_ALIAS\
{\
return [(LUA_VIEW_CONTROLLER) findViewById: @#VIEW_ID];\
}
