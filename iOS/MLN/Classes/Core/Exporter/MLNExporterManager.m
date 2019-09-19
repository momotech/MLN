//
//  MLNExporterManager.m
//  MLNCore
//
//  Created by MoMo on 2019/7/24.
//

#import "MLNExporterManager.h"
#import "MLNEntityExporter.h"
#import "MLNGlobalFuntionExporter.h"
#import "MLNGlobalVarExporter.h"
#import "MLNStaticExporter.h"

@interface MLNExporterManager ()

@property (nonatomic, strong) MLNExporter *staticExporter;
@property (nonatomic, strong) MLNExporter *entityExporter;
@property (nonatomic, strong) MLNExporter *globalVarExporter;
@property (nonatomic, strong) MLNExporter *globalFuncExporter;

@end
@implementation MLNExporterManager

- (BOOL)exportClass:(Class<MLNExportProtocol>)clazz error:(NSError * _Nullable __autoreleasing *)error
{
    MLNExporter *exporter = [self getExporter:clazz];
    return [exporter exportClass:clazz error:error];
}

- (MLNExporter *)getExporter:(Class<MLNExportProtocol>)clazz
{
    switch ([clazz mln_exportType]) {
        case MLNExportTypeStatic:
            return self.staticExporter;
        case MLNExportTypeEntity:
            return self.entityExporter;
        case MLNExportTypeGlobalVar:
            return self.globalVarExporter;
        case MLNExportTypeGlobalFunc:
            return self.globalFuncExporter;
        default:
            break;
    }
    return NULL;
}

#pragma mark - Getter
- (MLNExporter *)staticExporter
{
    if (!_staticExporter) {
        _staticExporter = [[MLNStaticExporter alloc] initWithLuaCore:self.luaCore];
    }
    return _staticExporter;
}

- (MLNExporter *)entityExporter
{
    if (!_entityExporter) {
        _entityExporter = [[MLNEntityExporter alloc] initWithLuaCore:self.luaCore];
    }
    return _entityExporter;
}

- (MLNExporter *)globalVarExporter
{
    if (!_globalVarExporter) {
        _globalVarExporter = [[MLNGlobalVarExporter alloc] initWithLuaCore:self.luaCore];
    }
    return _globalVarExporter;
}

- (MLNExporter *)globalFuncExporter
{
    if (!_globalFuncExporter) {
        _globalFuncExporter = [[MLNGlobalFuntionExporter alloc] initWithLuaCore:self.luaCore];
    }
    return _globalFuncExporter;
}

@end
