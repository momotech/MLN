//
//  MLNUIKitLuaCoreBuilder.h
//  MLNUI
//
//  Created by MoMo on 2019/11/22.
//

#import <Foundation/Foundation.h>
#import "MLNUIKitLuaCoeBuilderProtocol.h"
#import "MLNUIConvertorProtocol.h"
#import "MLNUIExporterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNUILuaCore;
@class MLNUILuaBundle;
@interface MLNUIKitLuaCorePool : NSObject <MLNUIKitLuaCoeBuilderProtocol>

- (instancetype)initWithWithLuaBundle:(MLNUILuaBundle *__nullable)luaBundle convertor:(Class<MLNUIConvertorProtocol> __nullable)convertorClass exporter:(Class<MLNUIExporterProtocol> __nullable)exporterClass;

- (void)preload;
- (void)preloadWithCapacity:(NSUInteger)capacity;

@end

NS_ASSUME_NONNULL_END
