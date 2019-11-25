//
//  MLNKitLuaCoreBuilder.m
//  MLN
//
//  Created by tamer on 2019/11/22.
//

#import "MLNKitLuaCorePool.h"
#import "MLNKitBridgesManager.h"
#import "MLNLuaCore.h"
#import "MLNKiConvertor.h"

@interface MLNKitLuaCorePool ()

@property (nonatomic) Class<MLNConvertorProtocol> convertorClass;
@property (nonatomic) Class<MLNExporterProtocol> exporterClass;
@property (nonatomic, strong) MLNLuaBundle *luaBundle;
@property (nonatomic, strong) MLNKitBridgesManager *bridgeManager;
@property (nonatomic, strong) NSMutableArray *luaCoreQueue;
@property (nonatomic, assign) NSUInteger capacity;

@end
@implementation MLNKitLuaCorePool

- (instancetype)initWithWithLuaBundle:(MLNLuaBundle *__nullable)luaBundle convertor:(Class<MLNConvertorProtocol> __nullable)convertorClass exporter:(Class<MLNExporterProtocol> __nullable)exporterClass
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
        _convertorClass = MLNKiConvertor.class;
        _bridgeManager = [[MLNKitBridgesManager alloc] init];
        _luaCoreQueue = [NSMutableArray array];
    }
    return self;
}

- (MLNLuaCore *)getLuaCore
{
    MLNLuaCore *luaCore = [self.luaCoreQueue firstObject];
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
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            MLNLuaCore *luaCore = [self buildLuaCore];
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

- (MLNLuaCore *)buildLuaCore
{
    MLNLuaCore *luaCore = [[MLNLuaCore alloc] initWithLuaBundle:self.luaBundle convertor:self.convertorClass exporter:self.exporterClass];
    [self.bridgeManager registerKitForLuaCore:luaCore];
    return luaCore;
}

@end
