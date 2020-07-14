//
//  MLNUIStaticFuncExportProtocol.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/7/7.
//

#ifndef MLNUIStaticFuncExportProtocol_h
#define MLNUIStaticFuncExportProtocol_h

#import "MLNUIStaticExportProtocol.h"

/**
 全局函数导出协议
 */
@protocol MLNUIStaticFuncExportProtocol <MLNUIExportProtocol>

/**
 被导出类的映射信息

 @return 映射信息
 */
+ (const mlnui_objc_class *)mlnui_clazzInfo;

@end


#endif /* MLNUIStaticFuncExportProtocol_h */
