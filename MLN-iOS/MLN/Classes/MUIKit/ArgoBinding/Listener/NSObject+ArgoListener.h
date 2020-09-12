//
//  NSObject+ArgoListener.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#import <Foundation/Foundation.h>
#import "ArgoListenerProtocol.h"
#import "ArgoObservableMap.h"
#import "ArgoObservableArray.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArgoObservableMap (ArgoListener) <ArgoListenerProtocol>
@end

@interface ArgoObservableArray (ArgoListener) <ArgoListenerProtocol, ArgoListenerForLuaArray>
@end

NS_ASSUME_NONNULL_END
