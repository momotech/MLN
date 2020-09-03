//
//  ArgoWatchWrapper.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/9/3.
//

#import <Foundation/Foundation.h>
#import "ArgoListenerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ArgoWatchBlock)(id oldValue, id newValue, id observedObject);

typedef NS_ENUM(NSUInteger, ArgoWatchContext) {
    ArgoWatchContext_Native,
    ArgoWatchContext_Lua
};

typedef BOOL(^ArgoFilterBlock)(ArgoWatchContext context, id newValue);

//只监听lua层的修改
extern ArgoFilterBlock kArgoFilter_Lua;
//只监听native层的修改
extern ArgoFilterBlock kArgoFilter_Native;


@interface ArgoWatchWrapper : NSObject

@property (nonatomic, copy, readonly) ArgoWatchWrapper *(^filter)(ArgoFilterBlock block);
@property (nonatomic, copy, readonly) ArgoWatchWrapper *(^callback)(ArgoWatchBlock block);

+ (instancetype)wrapperWithKeyPath:(NSString *)keyPath observedObject:(id<ArgoListenerProtocol>)observedObject;

@end

NS_ASSUME_NONNULL_END
