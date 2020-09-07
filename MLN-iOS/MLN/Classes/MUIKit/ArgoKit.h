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
#else
#define ArgoObservableMap NSObject
#define ArgoObservableArray NSMutableArray
#endif

#endif /* ArgoKit_h */
