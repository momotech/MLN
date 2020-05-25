//
//  MLNUIExport.h
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#ifndef MLNUIExport_h
#define MLNUIExport_h

#import <Foundation/Foundation.h>
#import "MLNUIExportInfo.h"

typedef enum : NSUInteger {
    /* 不可导出 */
    MLNUIExportTypeNone = 0,
    /* 静态导出类型 */
    MLNUIExportTypeStatic,
    /* 实体（UserData）导出类型 */
    MLNUIExportTypeEntity,
    /* 全局变量导出类型 */
    MLNUIExportTypeGlobalVar,
    /* 全局函数导出类型 */
    MLNUIExportTypeGlobalFunc,
} MLNUIExportType;

@class MLNUICore;
/**
 可导出类协议
 */
@protocol MLNUIExportProtocol <NSObject>

+ (MLNUIExportType)mln_exportType;

@end

#endif /* MLNUIExport_h */
