//
//  MLNUIKitLuaCoreBuilder.m
//  MLNUI
//
//  Created by MoMo on 2019/11/22.
//

#import "MLNUIKitLuaCorePool.h"
#import "MLNUIKitBridgesManager.h"
#import "MLNUILuaCore.h"
#import "MLNUIKiConvertor.h"
#import "ArgoBindingConvertor.h"

@interface MLNUIKitLuaCorePool ()

@property (nonatomic) Class<MLNUIConvertorProtocol> convertorClass;
@property (nonatomic) Class<MLNUIExporterProtocol> exporterClass;
@property (nonatomic, strong) MLNUILuaBundle *luaBundle;
@property (nonatomic, strong) MLNUIKitBridgesManager *bridgeManager;
@property (nonatomic, strong) NSMutableArray *luaCoreQueue;
@property (nonatomic, assign) NSUInteger capacity;

@end
@implementation MLNUIKitLuaCorePool

- (instancetype)initWithWithLuaBundle:(MLNUILuaBundle *__nullable)luaBundle convertor:(Class<MLNUIConvertorProtocol> __nullable)convertorClass exporter:(Class<MLNUIExporterProtocol> __nullable)exporterClass
{
    if (self = [self init]) {
        _convertorClass = convertorClass;
        _exporterClass = exporterClass;
        _capacity = 1;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _convertorClass = ArgoBindingConvertor.class;
        _bridgeManager = [[MLNUIKitBridgesManager alloc] init];
        _luaCoreQueue = [NSMutableArray array];
    }
    return self;
}

- (MLNUILuaCore *)getLuaCore
{
    MLNUILuaCore *luaCore = [self.luaCoreQueue firstObject];
    if (!luaCore) {
        luaCore = [self buildLuaCore];
    } else {
        [self.luaCoreQueue removeObjectAtIndex:0];
    }
    [self preload];
    return luaCore;
}

- (void)preload
{
    if (self.luaCoreQueue.count < self.capacity) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
            MLNUILuaCore *luaCore = [self buildLuaCore];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.luaCoreQueue addObject:luaCore];
                [self preload];
            });
        });
    }
}

- (void)preloadWithCapacity:(NSUInteger)capacity
{
    self.capacity = capacity;
    [self preload];
}

- (MLNUILuaCore *)buildLuaCore
{
    MLNUILuaCore *luaCore = [[MLNUILuaCore alloc] initWithLuaBundle:self.luaBundle convertor:self.convertorClass exporter:self.exporterClass];
    [self.bridgeManager registerKitForLuaCore:luaCore];
    return luaCore;
}

@end
