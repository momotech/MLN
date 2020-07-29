//
//  MLNUIPerformanceHeader.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/7/9.
//

#ifndef MLNUIPerformanceHeader_h
#define MLNUIPerformanceHeader_h

typedef NS_ENUM(NSUInteger, MLNUILoadTimeStatisticsType) {
    MLNUILoadTimeStatisticsType_Total = 0,
    MLNUILoadTimeStatisticsType_LuaCore,
    MLNUILoadTimeStatisticsType_ReadFile,
    MLNUILoadTimeStatisticsType_Compile,
    MLNUILoadTimeStatisticsType_Execute,
    MLNUILoadTimeStatisticsType_Custom,
};

/*
 MLNUILoadTimeStatisticsType_StartALL = 0,
 MLNUILoadTimeStatisticsType_StartLuaCore,
 MLNUILoadTimeStatisticsType_StartReadFile,
 MLNUILoadTimeStatisticsType_StartCompile,
 MLNUILoadTimeStatisticsType_StartExecute,
 MLNUILoadTimeStatisticsType_StartCustom,
 */
//typedef NS_ENUM(NSUInteger, MLNUILoadTimeStatisticsEndType) {
//    MLNUILoadTimeStatisticsType_EndAll,
//    MLNUILoadTimeStatisticsType_EndLuaCore,
//    MLNUILoadTimeStatisticsType_EndReadFile,
//    MLNUILoadTimeStatisticsType_EndCompile,
//    MLNUILoadTimeStatisticsType_EndExeCute,
//    MLNUILoadTimeStatisticsType_EndCustom
//};


@protocol MLNUIPerformanceMonitor <NSObject>

- (void)onStart:(MLNUILoadTimeStatisticsType)type tag:(NSString *)tag;
- (void)onEnd:(MLNUILoadTimeStatisticsType)type tag:(NSString *)tag info:(NSString *)info;
- (void)display;

//- (void)callOCBridge:(Class)cls selector:(SEL)sel;
//- (void)callDBBridge:(const char *)func;
//- (void)callCBridge:(const char *)func;

- (void)onStartCallOCBridge:(Class)cls selector:(SEL)sel;
- (void)onEndCallOCBridge:(Class)cls selector:(SEL)sel;

- (void)onStartCallCBridge:(const char *)func;
- (void)onEndCallCBridge:(const char *)func;

- (void)onStartCallDBBridge:(const char *)func;
- (void)onEndCallDBBridge:(const char *)func;

@end

#endif /* MLNUIPerformanceHeader_h */
