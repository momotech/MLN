//
//  MLNUIModelHandler.h
//  ArgoUI
//
//  Created by MOMO on 2020/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNUILuaCore;

@interface MLNUIModelHandler : NSObject

+ (__kindof NSObject *)buildModelWithDataObject:(id)dataObject model:(NSObject *)model extra:(id _Nullable)extra functionChunk:(const char *)functionChunk luaCore:(MLNUILuaCore *)luaCore;

@end

NS_ASSUME_NONNULL_END
