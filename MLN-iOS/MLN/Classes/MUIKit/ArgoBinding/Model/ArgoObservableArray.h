//
//  ArgoObservableArray.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#import <Foundation/Foundation.h>
#import "ArgoWatchWrapper.h"
#import "ArgoObservableObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArgoObservableArray<ObjectType> : NSMutableArray<ObjectType> <ArgoObservableObject>
@property (nonatomic, copy, readonly) ArgoWatchArrayWrapper *(^watch)(void);
@end

NS_ASSUME_NONNULL_END
