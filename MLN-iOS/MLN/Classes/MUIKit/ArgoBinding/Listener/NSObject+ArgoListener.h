//
//  NSObject+ArgoListener.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#import <Foundation/Foundation.h>
#import "ArgoListenerProtocol.h"

NS_ASSUME_NONNULL_BEGIN
//只用于 ArgoObservableMap & ArgoObservableArray
@interface NSObject (ArgoListener) <ArgoListenerCategoryProtocol>

@end

NS_ASSUME_NONNULL_END
