//
//  ArgoObservableArray.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#import <Foundation/Foundation.h>
#import "ArgoListenerProtocol.h"
#import "ArgoWatchWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArgoObservableArray : NSMutableArray <ArgoListenerProtocol>
@property (nonatomic, copy, readonly) ArgoWatchArrayWrapper *(^watch)(void);
@end

NS_ASSUME_NONNULL_END
