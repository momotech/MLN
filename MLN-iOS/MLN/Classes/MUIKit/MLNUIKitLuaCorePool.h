//
//  MLNKitLuaCoreBuilder.h
//  MLN
//
//  Created by MoMo on 2019/11/22.
//

#import <Foundation/Foundation.h>
#import "MLNKitLuaCoeBuilderProtocol.h"
#import "MLNConvertorProtocol.h"
#import "MLNExporterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNLuaCore;
@class MLNLuaBundle;
@interface MLNKitLuaCorePool : NSObject <MLNKitLuaCoeBuilderProtocol>

- (instancetype)initWithWithLuaBundle:(MLNLuaBundle *__nullable)luaBundle convertor:(Class<MLNConvertorProtocol> __nullable)convertorClass exporter:(Class<MLNExporterProtocol> __nullable)exporterClass;

- (void)preload;
- (void)preloadWithCapacity:(NSUInteger)capacity;

@end

NS_ASSUME_NONNULL_END
