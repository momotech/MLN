//
//  ArgoObservableMap.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/25.
//

#import <Foundation/Foundation.h>
#import "ArgoWatchWrapper.h"
#import "ArgoObservableObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArgoObservableMap<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType> <ArgoObservableObject>

@property (nonatomic, copy, readonly) ArgoWatchWrapper *(^watch)(NSString *key);
@property (nonatomic, copy, readonly) ArgoWatchWrapper *(^watchValue)(NSString *keyPath);
@end

NS_ASSUME_NONNULL_END
