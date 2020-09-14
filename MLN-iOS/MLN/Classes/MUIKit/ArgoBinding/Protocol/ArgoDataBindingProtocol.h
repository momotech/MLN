//
//  ArgoDataBindingProtocol.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/28.
//

#ifndef ArgoDataBindingProtocol_h
#define ArgoDataBindingProtocol_h
#import "ArgoObservableObject.h"

@class ArgoDataBinding;
@protocol ArgoDataBindingProtocol <NSObject>

@property (nonatomic, strong, readonly) ArgoDataBinding * _Nonnull argo_dataBinding;

- (void)bindData:(NSObject <ArgoObservableObject> *_Nonnull)data;
- (void)bindData:(NSObject <ArgoObservableObject> *_Nonnull)data forKey:(NSString *_Nonnull)key;

@end

@interface UIViewController (ArgoDataBinding)

@property (nonatomic, strong, readonly) ArgoDataBinding * _Nonnull argo_dataBinding;
- (void)argo_addToSuperViewController:(UIViewController *_Nonnull)superVC frame:(CGRect) frame;

@end

#endif /* ArgoDataBindingProtocol_h */
