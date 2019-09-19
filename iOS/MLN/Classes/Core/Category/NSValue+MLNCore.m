//
//  NSValue+MLNCore.m
//  MLN
//
//  Created by MoMo on 2019/8/2.
//

#import "NSValue+MLNCore.h"
#import "NSObject+MLNCore.h"
#import "MLNHeader.h"

@implementation NSValue (MLNCore)

- (MLNNativeType)mln_nativeType
{
    return MLNNativeTypeValue;
}

- (BOOL)mln_isMultiple
{
    // 该类型默认需要自助转换，不直接当做UserData
    return YES;
}

- (NSArray *)mln_multipleParams
{
    if (MLNValueIsCGRect(self)) {
        CGRect rect = self.CGRectValue;
        return @[@(rect.origin.x),
                 @(rect.origin.y),
                 @(rect.size.width),
                 @(rect.size.height)];
    } else if (MLNValueIsCGSize(self)) {
        CGSize size = self.CGSizeValue;
        return @[@(size.width),
                 @(size.height)];
    } else if (MLNValueIsCGPoint(self)) {
        CGPoint origin = self.CGPointValue;
        return @[@(origin.x),
                 @(origin.y)];
    }
    return nil;
}

@end
