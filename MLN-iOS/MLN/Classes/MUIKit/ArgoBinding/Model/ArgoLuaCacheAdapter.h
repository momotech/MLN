//
//  ArgoLuaCacheAdapter.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/9/1.
//

#import <Foundation/Foundation.h>
#import "ArgoListenerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArgoLuaCacheAdapter : NSObject <ArgoListenerLuaTableProtocol>
- (instancetype)initWithObject:(id<ArgoListenerProtocol>)object;
@end

//map interface
@interface ArgoLuaCacheAdapter ()
- (void)putValue:(NSObject *)value forKey:(NSString *)key;
- (void)removeAll;
@end

// array interface
@interface ArgoLuaCacheAdapter ()
- (void)notifyChange:(NSDictionary *)change;
@end

NS_ASSUME_NONNULL_END
