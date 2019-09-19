//
//  MLNTransform.m
//  
//
//  Created by MoMo on 2019/3/14.
//

#import "MLNTransformTask.h"
#import "MLNKitHeader.h"

@implementation MLNTransformTask

- (instancetype)initWithTargetView:(UIView *)targetView
{
    if (self = [super init]) {
        _target = targetView;
        _transform = CGAffineTransformIdentity;
    }
    return self;
}

- (void)setTransform:(CGAffineTransform)transform
{
    if (!CGAffineTransformEqualToTransform(_transform, transform)) {
        _transform = transform;
        if ([self mln_isConvertible]) {
            MLNKitInstance *instance = MLN_KIT_INSTANCE([(UIView<MLNEntityExportProtocol> *)self mln_luaCore]);
            [instance pushAnimation:self];
        }
    }
}

- (void)doTask
{
    self.target.transform = self.transform;
}

@end
