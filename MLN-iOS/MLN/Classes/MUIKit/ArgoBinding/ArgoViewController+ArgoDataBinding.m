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

@implementation ArgoViewController (ArgoDataBinding)

- (void)bindData:(NSObject *)data {
    [self.argo_dataBinding bindData:data];
}

- (void)bindData:(NSObject *)data forKey:(NSString *)key {
    [self.argo_dataBinding bindData:data forKey:key];
}

- (ArgoDataBinding *)argo_dataBinding {
    if (!_dataBinding) {
        _dataBinding = [[ArgoDataBinding alloc] init];
#if DEBUG
        @weakify(self);
        _dataBinding.errorLog = ^(NSString * _Nonnull log) {
            @strongify(self);
            MLNUIError(self.kitInstance.luaCore, @"%@",log);
        };
#endif
    }
    return _dataBinding;
}

@end

@implementation UIViewController (ArgoDataBinding)

- (ArgoDataBinding *)argo_dataBinding {
    ArgoDataBinding *obj = objc_getAssociatedObject(self, _cmd);
    if (!obj) {
        obj = [[ArgoDataBinding alloc] init];
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
@end
