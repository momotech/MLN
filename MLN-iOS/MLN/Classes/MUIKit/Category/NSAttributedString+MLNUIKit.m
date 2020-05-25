//
//  NSAttributedString+MLNKit.m
//
//
//  Created by MoMo on 2019/4/26.
//

#import "NSAttributedString+MLNKit.h"
#import <objc/runtime.h>
#import "NSObject+MLNCore.h"
#import "MLNStyleString.h"
#import "MLNWeakAssociatedObject.h"

static const void *kLuaDeallocBlock = &kLuaDeallocBlock;
static const void *kLuaStyleString = &kLuaStyleString;

@interface NSAttributedString( )

@end

@implementation NSAttributedString (MLNKit)

- (void)setLua_styleString:(MLNStyleString *)lua_styleString
{
    MLNWeakAssociatedObject *proxy = [MLNWeakAssociatedObject weakAssociatedObject:lua_styleString];
    objc_setAssociatedObject(self, &kLuaStyleString, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNStyleString *)lua_styleString
{
    MLNWeakAssociatedObject *proxy = objc_getAssociatedObject(self, &kLuaStyleString);
    return proxy.associatedObject;
}



@end
