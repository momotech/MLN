//
//  ArgoKit.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/31.
//

#ifndef ArgoKit_h
#define ArgoKit_h

#import "MLNUIKit.h"
#import "MLNUIHeader.h"

#import "ArgoObservableMap.h"
#import "ArgoObservableArray.h"

#if OCPERF_USE_NEW_DB
#import "NSDictionary+MLNUIKVO.h"
#import "NSArray+MLNUIKVO.h"
#else
#define ArgoObservableMap NSObject
#define ArgoObservableArray NSMutableArray
#define argo_mutableCopy mutableCopy
#endif

#endif /* ArgoKit_h */
