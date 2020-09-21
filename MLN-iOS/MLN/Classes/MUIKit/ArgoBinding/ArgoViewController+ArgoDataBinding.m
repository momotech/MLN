//
//  ArgoViewController+ArgoDataBinding.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/28.
//

#import "ArgoViewController+ArgoDataBinding.h"
#import "ArgoDataBinding.h"
#import "MLNUILuaCore.h"
#import "MLNUIKitInstance.h"
#import "MLNUIExtScope.h"
#import "MLNUIDataBinding.h"
#import "MLNUIHeader.h"

@implementation ArgoViewController (ArgoDataBinding)

- (void)bindData:(NSObject<ArgoObservableObject> *)data {
    [self.argo_dataBinding bindData:(NSObject<ArgoListenerProtocol> *)data];
}

- (void)bindData:(NSObject<ArgoObservableObject> *)data forKey:(NSString *)key {
    [self.argo_dataBinding bindData:(NSObject<ArgoListenerProtocol> *)data forKey:key];
}

- (ArgoDataBinding *)argo_dataBinding {
    if (!_dataBinding) {
        ArgoDataBindingErrorLogBlock block;
#if DEBUG
        @weakify(self);
        block = ^(NSString * _Nonnull log) {
            @strongify(self);
            MLNUIError(self.kitInstance.luaCore, @"%@",log);
        };
#endif
        _dataBinding = [self.class argo_createDataBindingWithErrorLogBlock:block];
    }
    return _dataBinding;
}

- (MLNUIDataBinding *)mlnui_dataBinding {
    return (MLNUIDataBinding *)[self argo_dataBinding];
}

@end

@implementation UIViewController (ArgoDataBinding)

+ (ArgoDataBinding *_Nonnull)argo_createDataBindingWithErrorLogBlock:(ArgoDataBindingErrorLogBlock _Nullable )block {
    ArgoDataBinding *db = [[ArgoDataBinding alloc] init];
# if OCPERF_USE_NEW_DB
    db = [[ArgoDataBinding alloc] init];
#else
    db = (ArgoDataBinding *)[[MLNUIDataBinding alloc] init];
#endif
    db.errorLog = block;
    return db;
}

- (ArgoDataBinding *)argo_dataBinding {
    ArgoDataBinding *obj = objc_getAssociatedObject(self, _cmd);
    if (!obj) {
# if OCPERF_USE_NEW_DB
        obj = [[ArgoDataBinding alloc] init];
#else
        obj = [[MLNUIDataBinding alloc] init];
#endif
        objc_setAssociatedObject(self, _cmd, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obj;
}

- (void)argo_addToSuperViewController:(UIViewController *)superVC frame:(CGRect) frame {
    if (superVC) {
        [superVC addChildViewController:self];
        self.view.frame = frame;
        [superVC.view addSubview:self.view];
        [self didMoveToParentViewController:superVC];
    }
}

- (void)argo_bindData:(NSObject<ArgoObservableObject> *)data {
    [self.argo_dataBinding bindData:(NSObject<ArgoListenerProtocol> *)data];
}

- (void)argo_bindData:(NSObject<ArgoObservableObject> *)data forKey:(NSString *)key {
    [self.argo_dataBinding bindData:(NSObject<ArgoListenerProtocol> *)data forKey:key];
}

@end
