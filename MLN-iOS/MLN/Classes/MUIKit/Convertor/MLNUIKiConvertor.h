//
//  MLNUIKiConvertor.h
//  MLNUI
//
//  Created by MoMo on 2019/8/2.
//

#import "MLNUIConvertor.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Lua 与 原生之间的数据转换器
 
 @note Native to Lua 类型转换规则如下：
        NSDictionary -> Lua table
        NSMutableDictionary -> Map
        NSArray -> Lua table
        NSMutableArray -> Array
        NSValue.CGRect -> x,y,width,height 4个number
        NSValue.CGPoint -> x,y 2个number
        NSValue.CGSize -> width,height 2个number
        UIColor -> Color
        CGRect -> Rect
        CGPoint -> Point
        CGSize -> Size
        NSString -> string
        int、float、CGFloat ... -> number
        BOOL -> boolean
        ...
 
       Lua to Native 类型转换规则如下：
        Lua table -> NSDictionary 或 NSArray
        Map ->  NSMutableDictionary
        Array -> NSMutableArray
        {x,y,width,height} 或 {x = ... ,y = ..., width = ..., height = ...} 或 Rect -> CGRect
        {x,y} 或 {x = ... ,y = ...} 或 Point -> CGPoint
        {width,height} 或 {width = ..., height = ...} 或 Size -> CGSize
        Color -> UIColor
        string -> NSString 、 const char *
        number -> int、float、CGFloat...
        boolean -> BOOL
 */
@interface MLNUIKiConvertor : MLNUIConvertor

@end

NS_ASSUME_NONNULL_END
