//
//  ArgoWatchWrapper.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/9/3.
//

#import <Foundation/Foundation.h>
#import "ArgoKitDefinitions.h"
 
NS_ASSUME_NONNULL_BEGIN
@class ArgoObservableMap, ArgoObservableArray;

typedef void(^ArgoWatchBlock)(id oldValue, id newValue, ArgoObservableMap *map);
typedef void(^ArgoWatchArrayBlock)(ArgoObservableArray *array, NSDictionary *change);

typedef BOOL(^ArgoFilterBlock)(ArgoWatchContext context, id newValue);
//只监听lua层的修改
extern ArgoFilterBlock kArgoFilter_Lua;
//只监听native层的修改
extern ArgoFilterBlock kArgoFilter_Native;


#pragma mark - 
@interface ArgoWatchWrapper : NSObject

@property (nonatomic, copy, readonly) ArgoWatchWrapper *(^filter)(ArgoFilterBlock block);
@property (nonatomic, copy, readonly) ArgoWatchWrapper *(^callback)(ArgoWatchBlock block);

+ (instancetype)wrapperWithKeyPath:(NSString *)keyPath observedObject:(ArgoObservableMap *)observedObject;
- (void)unwatch;

@end

@interface ArgoWatchArrayWrapper : NSObject

@property (nonatomic, copy, readonly) ArgoWatchArrayWrapper *(^filter)(ArgoFilterBlock block);
@property (nonatomic, copy, readonly) ArgoWatchArrayWrapper *(^callback)(ArgoWatchArrayBlock block);
+ (instancetype)wrapperWithObservedObject:(ArgoObservableArray *)observedObject;
- (void)unwatch;

@end

NS_ASSUME_NONNULL_END
