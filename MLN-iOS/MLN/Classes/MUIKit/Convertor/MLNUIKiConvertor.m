//
//  MLNUIKiConvertor.m
//  MLNUI
//
//  Created by MoMo on 2019/8/2.
//

#import "MLNUIKiConvertor.h"
#import "MLNUIRect.h"
#import "MLNUISize.h"
#import "MLNUIPoint.h"
#import "MLNUILuaCore.h"
#import "NSObject+MLNUICore.h"
#import "NSValue+MLNUICore.h"
#import "MLNUIEntityExportProtocol.h"
#import "NSError+MLNUICore.h"
#import "MLNUIColor.h"

@implementation MLNUIKiConvertor

- (int)pushNativeObject:(id)obj error:(NSError *__autoreleasing *)error
{
    if ([obj mlnui_nativeType] == MLNUINativeTypeColor) {
        obj = [[MLNUIColor alloc] initWithColor:(UIColor *)obj];
    }
    return [super pushNativeObject:obj error:error];
}

- (int)pushCGRect:(CGRect)rect error:(NSError **)error
{
    return [super pushValua:[MLNUIRect rectWithCGRect:rect] error:error];
}

- (int)pushCGPoint:(CGPoint)point error:(NSError **)error
{
    return [super pushValua:[MLNUIPoint pointWithCGPoint:point] error:error];
}

- (int)pushCGSize:(CGSize)size error:(NSError **)error
{
    return [super pushValua:[MLNUISize sizeWithCGSize:size] error:error];
}

@end
