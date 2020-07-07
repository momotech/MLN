//
//  MLNUIExporterManager.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/24.
//

#import "MLNUIExporterManager.h"
#import "MLNUIEntityExporter.h"
#import "MLNUIGlobalFuntionExporter.h"
#import "MLNUIGlobalVarExporter.h"
#import "MLNUIStaticExporter.h"
#import "MLNUIStaticFunctionExporter.h"

@interface MLNUIExporterManager ()

@property (nonatomic, strong) MLNUIExporter *staticExporter;
@property (nonatomic, strong) MLNUIExporter *entityExporter;
@property (nonatomic, strong) MLNUIExporter *globalVarExporter;
@property (nonatomic, strong) MLNUIExporter *globalFuncExporter;
@property (nonatomic, strong) MLNUIExporter *staticFuncExporter;
@end
@implementation MLNUIExporterManager

- (BOOL)exportClass:(Class<MLNUIExportProtocol>)clazz error:(NSError * _Nullable __autoreleasing *)error
{
    MLNUIExporter *exporter = [self getExporter:clazz];
    return [exporter exportClass:clazz error:error];
}

- (MLNUIExporter *)getExporter:(Class<MLNUIExportProtocol>)clazz
{
    switch ([clazz mlnui_exportType]) {
        case MLNUIExportTypeStatic:
            return self.staticExporter;
        case MLNUIExportTypeEntity:
            return self.entityExporter;
        case MLNUIExportTypeGlobalVar:
            return self.globalVarExporter;
        case MLNUIExportTypeGlobalFunc:
            return self.globalFuncExporter;
        case MLNUIExportTypeStaticFunc:
            return self.staticFuncExporter;
        default:
            break;
    }
    return NULL;
}

#pragma mark - Getter
- (MLNUIExporter *)staticExporter
{
    if (!_staticExporter) {
        _staticExporter = [[MLNUIStaticExporter alloc] initWithMLNUILuaCore:self.luaCore];
    }
    return _staticExporter;
}

- (MLNUIExporter *)entityExporter
{
    if (!_entityExporter) {
        _entityExporter = [[MLNUIEntityExporter alloc] initWithMLNUILuaCore:self.luaCore];
    }
    return _entityExporter;
}

- (MLNUIExporter *)globalVarExporter
{
    if (!_globalVarExporter) {
        _globalVarExporter = [[MLNUIGlobalVarExporter alloc] initWithMLNUILuaCore:self.luaCore];
    }
    return _globalVarExporter;
}

- (MLNUIExporter *)globalFuncExporter
{
    if (!_globalFuncExporter) {
        _globalFuncExporter = [[MLNUIGlobalFuntionExporter alloc] initWithMLNUILuaCore:self.luaCore];
    }
    return _globalFuncExporter;
}

- (MLNUIExporter *)staticFuncExporter {
    if (!_staticFuncExporter) {
        _staticFuncExporter = [[MLNUIStaticFunctionExporter alloc] initWithMLNUILuaCore:self.luaCore];
    }
    return _staticFuncExporter;
}

@end
