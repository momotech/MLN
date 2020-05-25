//
//  NSValue+MLNUICore.m
//  MLNUI
//
//  Created by MoMo on 2019/8/2.
//

#import "NSValue+MLNUICore.h"
#import "NSObject+MLNUICore.h"
#import "MLNUIHeader.h"

@implementation NSValue (MLNUICore)

- (MLNUINativeType)mln_nativeType
{
    return MLNUINativeTypeValue;
}

- (BOOL)mln_isMultiple
{
    // 该类型默认需要自助转换，不直接当做UserData
    return YES;
}

- (NSArray *)mln_multipleParams
{
    if (MLNUIValueIsCGRect(self)) {
        CGRect rect = self.CGRectValue;
        return @[@(rect.origin.x),
                 @(rect.origin.y),
                 @(rect.size.width),
                 @(rect.size.height)];
    } else if (MLNUIValueIsCGSize(self)) {
        CGSize size = self.CGSizeValue;
        return @[@(size.width),
                 @(size.height)];
    } else if (MLNUIValueIsCGPoint(self)) {
        CGPoint origin = self.CGPointValue;
        return @[@(origin.x),
                 @(origin.y)];
    }
    return nil;
}

@end
