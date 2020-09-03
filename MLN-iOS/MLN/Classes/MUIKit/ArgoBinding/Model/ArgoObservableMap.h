//
//  ArgoObservableMap.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/25.
//

#import <Foundation/Foundation.h>
#import "ArgoListenerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArgoObservableMap : NSMutableDictionary <ArgoListenerProtocol>
@end

NS_ASSUME_NONNULL_END
