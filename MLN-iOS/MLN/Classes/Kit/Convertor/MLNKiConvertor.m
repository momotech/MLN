//
//  MLNKiConvertor.m
//  MLN
//
//  Created by MoMo on 2019/8/2.
//

#import "MLNKiConvertor.h"
#import "MLNRect.h"
#import "MLNSize.h"
#import "MLNPoint.h"
#import "MLNLuaCore.h"
#import "NSObject+MLNCore.h"
#import "NSValue+MLNCore.h"
#import "MLNEntityExportProtocol.h"
#import "NSError+MLNCore.h"
#import "MLNColor.h"

@implementation MLNKiConvertor

- (int)pushNativeObject:(id)obj error:(NSError *__autoreleasing *)error
{
    if ([obj mln_nativeType] == MLNNativeTypeColor) {
        obj = [[MLNColor alloc] initWithColor:(UIColor *)obj];
    }
    return [super pushNativeObject:obj error:error];
}

- (int)pushCGRect:(CGRect)rect error:(NSError **)error
{
    return [super pushValua:[MLNRect rectWithCGRect:rect] error:error];
}

- (int)pushCGPoint:(CGPoint)point error:(NSError **)error
{
    return [super pushValua:[MLNPoint pointWithCGPoint:point] error:error];
}

- (int)pushCGSize:(CGSize)size error:(NSError **)error
{
    return [super pushValua:[MLNSize sizeWithCGSize:size] error:error];
}

@end
