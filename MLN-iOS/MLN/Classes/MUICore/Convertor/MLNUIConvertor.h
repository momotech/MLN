//
//  MLNUIConvertor.h
//  MLNUICore
//
//  Created by MoMo on 2019/7/25.
//

#import <Foundation/Foundation.h>
#import "MLNUIConvertorProtocol.h"

typedef enum : int {
    MLNUI_OBJCType_ndef = 0, // 未定义
    MLNUI_OBJCType_void,
    MLNUI_OBJCType_BOOL, // BOOL , bool
    MLNUI_OBJCType_char, // BOOL , bool
    MLNUI_OBJCType_uchar,
    MLNUI_OBJCType_short,
    MLNUI_OBJCType_ushort,
    MLNUI_OBJCType_int, // int , NSInteger
    MLNUI_OBJCType_uint,  // int , NSUInteger
    MLNUI_OBJCType_long, //  long , NSInteger
    MLNUI_OBJCType_ulong, // unsigned long , NSUInteger
    MLNUI_OBJCType_llong, //long long, NSInteger
    MLNUI_OBJCType_ullong, // unsigned long long, NSUInteger
    MLNUI_OBJCType_float, // float, CGFloat
    MLNUI_OBJCType_double, // double, CGFloat
    MLNUI_OBJCType_char_ptr, // char *, unsigned char *
    MLNUI_OBJCType_const_char_ptr, //  const char *, const unsigned char *
    MLNUI_OBJCType_void_ptr, // void *
    MLNUI_OBJCType_id,
    MLNUI_OBJCType_block,
    MLNUI_OBJCType_class,
    MLNUI_OBJCType_id_ptr, // NSError **
    MLNUI_OBJCType_struct,
    MLNUI_OBJCType_struct_ptr,
    MLNUI_OBJCType_rect, // CGRect
    MLNUI_OBJCType_size, // CGSzie
    MLNUI_OBJCType_point, // CGPoint
    MLNUI_OBJCType_SEL, // SELECTOR
}MLNUI_Objc_Type;

NS_ASSUME_NONNULL_BEGIN

/**
 将objc类型字符串转换为对应的枚举值

 @param type objc类型字符串
 @return 对应的枚举值
 */
MLNUI_Objc_Type mlnui_objctype(const char *type);

/**
 Native 与 Lua数据转换工具
 */
@interface MLNUIConvertor : NSObject <MLNUIConvertorProtocol>

@end

NS_ASSUME_NONNULL_END
