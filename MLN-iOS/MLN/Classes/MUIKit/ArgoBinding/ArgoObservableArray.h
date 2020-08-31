//
//  ArgoObservableArray.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#import <Foundation/Foundation.h>
#import "ArgoListenerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArgoObservableArray : NSMutableArray <ArgoListenerProtocol>

@end

NS_ASSUME_NONNULL_END
