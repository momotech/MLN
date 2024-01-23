//
//  MLNImpoterManager.m
//  MLN
//
//  Created by xue.yunqiang on 2022/4/1.
//

#import "MLNImpoterManager.h"
#import "MLNEntityExporterMacro.h"
#import "MLNKitInstance.h"
#import "MLNMachORegister.h"

@interface MLNImpoterManager()

@property (nonatomic, strong) NSMutableDictionary<NSString *, Class> *allMLNExportMap;
@property (nonatomic, strong) NSMutableDictionary<NSString *, Class> *globalVarMap;

@end

@implementation MLNImpoterManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _allMLNExportMap = [NSMutableDictionary dictionary];
        _globalVarMap = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)shared
{
    static MLNImpoterManager *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[MLNImpoterManager alloc] init];
    });
    return obj;
}

- (void)readMDActionFormSectionIfNeed {
    if (_allMLNExportMap.count) {
        return;
    }
    NSSet * mlnImportBind = MLNMachORegisterGetVSetWithKey(MLNExportBindSectionNameSpace);
    if (mlnImportBind.count == 0) {
        NSString *errorString = [NSString stringWithFormat:@"【MLNImpoter Bind Error】%@ 读取注册信息失败!!",NSStringFromClass([self class])];
        if ([self.handle respondsToSelector:@selector(importerManagerSetupError:)]) {
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"Acess", @"type", errorString, @"message", nil];
            [self.handle importerManagerSetupError:info];
        }
        return;
    }
    __block NSString *logString = nil;
    __block NSMutableDictionary<NSString *, Class> *actionMap = nil;
    NSString *nameSpace = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleExecutable"];
    [mlnImportBind enumerateObjectsUsingBlock:^(NSString *item, BOOL * _Nonnull stop) {
        NSArray<NSString *> *array = [item componentsSeparatedByString:MLNExportBindSplit];
        if (array.count == 2) {
            NSString *luaClassName = array[0];
            NSString *nativeClassName = array[1];
            if ([luaClassName isKindOfClass:[NSString class]] &&
                luaClassName.length &&
                [nativeClassName isKindOfClass:[NSString class]] &&
                nativeClassName.length) {
                if (!actionMap) {
                    actionMap = [NSMutableDictionary dictionary];
                }
                Class oldNativeImplClass = actionMap[luaClassName];
                Class nativeImplClass = NSClassFromString(nativeClassName);
                if (nativeImplClass) {
                    if (oldNativeImplClass) {//has same lua class name in native?
                        if ([nativeImplClass isSubclassOfClass:oldNativeImplClass]) {//same name is form subclass
                            actionMap[luaClassName] = nativeImplClass;
                        } else if (![oldNativeImplClass isSubclassOfClass:nativeImplClass]) {//same name is form different
                            logString = [NSString stringWithFormat:@"错误的Bind项 lua class name: '%@', native class name is : '%@' and '%@', you need different lua class name", luaClassName,nativeClassName,NSStringFromClass(oldNativeImplClass)];
                        }
                    } else {
                        actionMap[luaClassName] = nativeImplClass;
                        if ([nativeImplClass conformsToProtocol:@protocol(MLNExportProtocol)]) {
                            if ([nativeImplClass mln_exportType] == MLNExportTypeGlobalVar) {
                                _globalVarMap[luaClassName] = nativeImplClass;
                            }
                        }
                    }
                } else {
                    NSString *swiftNativeClassName = [[nameSpace stringByAppendingString:@"."] stringByAppendingString:nativeClassName];
                    Class swiftNativeImplClass = NSClassFromString(swiftNativeClassName);
                    if (swiftNativeImplClass) {
                        if (oldNativeImplClass) {//has same lua class name in native?
                            if ([swiftNativeImplClass isSubclassOfClass:oldNativeImplClass]) {//same name is form subclass
                                actionMap[luaClassName] = swiftNativeImplClass;
                            } else if (![swiftNativeImplClass isSubclassOfClass:nativeImplClass]) {//same name is form different
                                logString = [NSString stringWithFormat:@"错误的Bind项 lua class name: '%@', native class name is : '%@' and '%@' , you need different lua class name", luaClassName,swiftNativeImplClass,NSStringFromClass(oldNativeImplClass)];
                                //                                NSAssert(!logString.length, logString);
                            }
                        } else {
                            actionMap[luaClassName] = swiftNativeImplClass;
                            if ([nativeImplClass conformsToProtocol:@protocol(MLNExportProtocol)]) {
                                if ([nativeImplClass mln_exportType] == MLNExportTypeGlobalVar) {
                                    _globalVarMap[luaClassName] = swiftNativeImplClass;
                                }
                            }
                        }
                    } else {
                        logString = [NSString stringWithFormat:@"错误的Bind项 actionName:%@ actionImpl:%@，class不存在", luaClassName,nativeClassName];
                    }
                }
            }
        } else {
            logString = [NSString stringWithFormat:@"错误的Bind项 %@", item];
        }
        if (logString.length) {
            NSLog(@"【MLNImpoter Bind Warning】%@",logString);
            if ([self.handle respondsToSelector:@selector(importerManagerSetupError:)]) {
                NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"setup", @"type", logString, @"message", nil];
                [self.handle importerManagerSetupError:info];
            }
            logString = nil;
        }
    }];
    
    if (actionMap.count > 0) {
        [_allMLNExportMap addEntriesFromDictionary:actionMap];
    }
}

- (BOOL)registBridge:(NSString *)className forInstance:(MLNKitInstance *)instance {
    [self readMDActionFormSectionIfNeed];
    if (className.length) {
        Class nativeClass = _allMLNExportMap[className];
        if (nativeClass) {
            NSError *error = nil;
            [instance registerClazz:nativeClass error:&error];
            if (!error) {
                return YES;
            } else {
                NSLog(@"【MLNImpoter registBridge Error】%@", [error description]);
            }
        }
    }
    return NO;
}

-(void)registMLNglobalVarForInstance:(MLNKitInstance *)instance {
    [self readMDActionFormSectionIfNeed];
    for (NSString *key in [self.globalVarMap allKeys]) {
        [self registBridge:key forInstance:instance];
    }
}

@end
