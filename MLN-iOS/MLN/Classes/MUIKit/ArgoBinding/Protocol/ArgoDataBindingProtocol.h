//
//  ArgoDataBindingProtocol.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/28.
//

#ifndef ArgoDataBindingProtocol_h
#define ArgoDataBindingProtocol_h
#import "ArgoObservableObject.h"

typedef void (^ArgoDataBindingErrorLogBlock)(NSString * _Nullable log);

@class ArgoDataBinding;
@protocol ArgoDataBindingProtocol <NSObject>

@property (nonatomic, strong, readonly) ArgoDataBinding * _Nonnull argo_dataBinding;

- (void)bindData:(NSObject <ArgoObservableObject> *_Nonnull)data;
- (void)bindData:(NSObject <ArgoObservableObject> *_Nonnull)data forKey:(NSString *_Nonnull)key;

@end

@interface UIViewController (ArgoDataBinding)

@property (nonatomic, strong, readonly) ArgoDataBinding * _Nonnull argo_dataBinding;

+ (ArgoDataBinding *_Nonnull)argo_createDataBindingWithErrorLogBlock:(ArgoDataBindingErrorLogBlock _Nullable )block;
- (void)argo_addToSuperViewController:(UIViewController *_Nonnull)superVC frame:(CGRect) frame;

- (void)argo_bindData:(NSObject <ArgoObservableObject> *_Nonnull)data;
- (void)argo_bindData:(NSObject <ArgoObservableObject> *_Nonnull)data forKey:(NSString *_Nonnull)key;

@end

#endif /* ArgoDataBindingProtocol_h */
