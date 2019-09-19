//
//  NSColor+MLNCore.m
//  MLNCore
//
//  Created by MoMo on 2019/7/23.
//

#import "UIColor+MLNCore.h"
#import "NSObject+MLNCore.h"

@implementation UIColor (MLNCore)

- (MLNNativeType)mln_nativeType
{
    return MLNNativeTypeColor;
}

@end
