//
//  ArgoUIKit.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/31.
//

#ifndef ArgoUIKit_h
#define ArgoUIKit_h

#import "MLNUIKit.h"
#import "MLNUIModelHandler.h"

#import "ArgoObservableMap.h"
#import "ArgoObservableArray.h"
#import "ArgoViewModelProtocol.h"

#import "MLNUIHeader.h"
#if OCPERF_USE_NEW_DB
#import "NSDictionary+MLNUIKVO.h"
#import "NSArray+MLNUIKVO.h"
#define ArgoViewModelBase ArgoObservableMap
#else
#define ArgoViewModelBase NSObject
#define ArgoObservableMap NSMutableDictionary
#define ArgoObservableArray NSMutableArray
#define argo_mutableCopy mutableCopy
#endif

#endif /* ArgoKit_h */
