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
    lua_getglobal(L, "layout");
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
    [self.dataBinding bindData:data forKey:key];
}

- (void)updateDataForKeyPath:(NSString *)keyPath value:(id)value {
    [self.dataBinding updateDataForKeyPath:keyPath value:value];
}

- (id __nullable)dataForKeyPath:(NSString *)keyPath {
    return [self.dataBinding dataForKeyPath:keyPath];
}

- (void)addDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath {
    [self.dataBinding addDataObserver:observer forKeyPath:keyPath];
}

- (void)removeDataObserver:(NSObject<MLNKVOObserverProtol> *)observer forKeyPath:(NSString *)keyPath {
    [self.dataBinding removeDataObserver:observer forKeyPath:keyPath];
}

- (void)addToSuperViewController:(UIViewController *)superVC frame:(CGRect) frame {
    [superVC addChildViewController:self];
    self.view.frame = frame;
    [superVC.view addSubview:self.view];
    [self didMoveToParentViewController:superVC];
}

- (MLNDataBinding *)dataBinding {
    if (!_dataBinding) {
        _dataBinding = [[MLNDataBinding alloc] init];
    }
    return _dataBinding;
}

@end

//@implementation MLNKitViewController (ArrayBinding)
//
//@end
