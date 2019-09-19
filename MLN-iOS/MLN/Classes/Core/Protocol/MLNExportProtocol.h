//
//  MLNExport.h
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#ifndef MLNExport_h
#define MLNExport_h

#import <Foundation/Foundation.h>
#import "MLNExportInfo.h"

typedef enum : NSUInteger {
    /* 不可导出 */
    MLNExportTypeNone = 0,
    /* 静态导出类型 */
    MLNExportTypeStatic,
    /* 实体（UserData）导出类型 */
    MLNExportTypeEntity,
    /* 全局变量导出类型 */
    MLNExportTypeGlobalVar,
    /* 全局函数导出类型 */
    MLNExportTypeGlobalFunc,
} MLNExportType;

@class MLNCore;
/**
 可导出类协议
 */
@protocol MLNExportProtocol <NSObject>

+ (MLNExportType)mln_exportType;

@end

#endif /* MLNExport_h */
