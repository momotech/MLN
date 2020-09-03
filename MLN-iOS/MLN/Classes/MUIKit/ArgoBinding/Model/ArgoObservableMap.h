//
//  ArgoObservableMap.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/25.
//

#import <Foundation/Foundation.h>
#import "ArgoListenerProtocol.h"
#import "ArgoWatchWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArgoObservableMap : NSMutableDictionary <ArgoListenerProtocol>

@property (nonatomic, copy, readonly) ArgoWatchWrapper *(^watch)(NSString *keyPath);

@end

NS_ASSUME_NONNULL_END
