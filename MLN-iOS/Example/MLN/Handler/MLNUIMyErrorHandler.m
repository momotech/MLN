//
//  MLNUIMyErrorHandler.m
//  LuaNative
//
//  Created by Dongpeng Dai on 2020/9/8.
//  Copyright © 2020 MoMo. All rights reserved.
//

#import "MLNUIMyErrorHandler.h"

@implementation MLNUIMyErrorHandler

- (BOOL)canHandleAssert:(MLNUIKitInstance *)instance {
    return YES;
}

- (void)instance:(MLNUIKitInstance *)instance error:(NSString *)error {
    NSLog(@"MLNUIMyErrorHandler1 :%@",error);
//    NSAssert(NO, error);
}

- (void)instance:(MLNUIKitInstance *)instance luaError:(NSString *)error luaTraceback:(NSString *)luaTraceback {
    NSLog(@"MLNUIMyErrorHandler2 :%@",error);
//    NSAssert(NO, error);
}

@end
