//
//  ArgoKuaViewModelUtils.h
//  LuaNative
//
//  Created by Dongpeng Dai on 2020/9/4.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArgoObservableMap.h"
#import "ArgoObservableArray.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArgoKuaViewModelUtils : NSObject

+ (ArgoObservableMap *)getKuaTestModel;

@end

NS_ASSUME_NONNULL_END
