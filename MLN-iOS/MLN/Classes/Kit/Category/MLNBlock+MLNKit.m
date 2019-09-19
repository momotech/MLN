//
//  MLNBlock+MLNKit.m
//  MLN
//
//  Created by MoMo on 2019/9/12.
//

#import "MLNBlock+MLNKit.h"

@implementation MLNBlock (MLNKit)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        Method origMethod1 = class_getInstanceMethod([self class], @selector(touchesBegan:withEvent:));
//        Method swizzledMethod1 = class_getInstanceMethod([self class], @selector(mln_in_touchesBegan:withEvent:));
//        __mln_in_UIView_Origin_TouchesBegan_Method_Imp = method_getImplementation(origMethod1);
//        method_exchangeImplementations(origMethod1, swizzledMethod1);
        
    });
}


@end
