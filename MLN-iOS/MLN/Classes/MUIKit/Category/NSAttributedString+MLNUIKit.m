//
//  NSAttributedString+MLNUIKit.m
//
//
//  Created by MoMo on 2019/4/26.
//

#import "NSAttributedString+MLNUIKit.h"
#import <objc/runtime.h>
#import "NSObject+MLNUICore.h"
#import "MLNUIStyleString.h"
#import "MLNUIWeakAssociatedObject.h"

static const void *kLuaDeallocBlock = &kLuaDeallocBlock;
static const void *kLuaStyleString = &kLuaStyleString;

@interface NSAttributedString( )

@end

@implementation NSAttributedString (MLNUIKit)

- (void)setLuaui_styleString:(MLNUIStyleString *)luaui_styleString
{
    MLNUIWeakAssociatedObject *proxy = [MLNUIWeakAssociatedObject weakAssociatedObject:luaui_styleString];
    objc_setAssociatedObject(self, &kLuaStyleString, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIStyleString *)luaui_styleString
{
    MLNUIWeakAssociatedObject *proxy = objc_getAssociatedObject(self, &kLuaStyleString);
    return proxy.associatedObject;
}



@end
