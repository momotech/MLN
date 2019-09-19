//
//  MLNConvertor.h
//  MLNCore
//
//  Created by MoMo on 2019/7/25.
//

#import <Foundation/Foundation.h>
#import "MLNConvertorProtocol.h"

typedef enum : int {
    MLN_OBJCType_ndef = 0, // 未定义
    MLN_OBJCType_void,
    MLN_OBJCType_BOOL, // BOOL , bool
    MLN_OBJCType_char, // BOOL , bool
    MLN_OBJCType_uchar,
    MLN_OBJCType_short,
    MLN_OBJCType_ushort,
    MLN_OBJCType_int, // int , NSInteger
    MLN_OBJCType_uint,  // int , NSUInteger
    MLN_OBJCType_long, //  long , NSInteger
    MLN_OBJCType_ulong, // unsigned long , NSUInteger
    MLN_OBJCType_llong, //long long, NSInteger
    MLN_OBJCType_ullong, // unsigned long long, NSUInteger
    MLN_OBJCType_float, // float, CGFloat
    MLN_OBJCType_double, // double, CGFloat
    MLN_OBJCType_char_ptr, // char *, unsigned char *
    MLN_OBJCType_const_char_ptr, //  const char *, const unsigned char *
    MLN_OBJCType_void_ptr, // void *
    MLN_OBJCType_id,
    MLN_OBJCType_block,
    MLN_OBJCType_class,
    MLN_OBJCType_id_ptr, // NSError **
    MLN_OBJCType_struct,
    MLN_OBJCType_struct_ptr,
    MLN_OBJCType_rect, // CGRect
    MLN_OBJCType_size, // CGSzie
    MLN_OBJCType_point, // CGPoint
    MLN_OBJCType_SEL, // SELECTOR
}MLN_Objc_Type;

NS_ASSUME_NONNULL_BEGIN

/**
 将objc类型字符串转换为对应的枚举值

 @param type objc类型字符串
 @return 对应的枚举值
 */
MLN_Objc_Type mln_objctype(const char *type);

/**
 Native 与 Lua数据转换工具
 */
@interface MLNConvertor : NSObject <MLNConvertorProtocol>

@end

NS_ASSUME_NONNULL_END
