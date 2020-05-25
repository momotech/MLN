//
//  MLNUITransform.m
//  
//
//  Created by MoMo on 2019/3/14.
//

#import "MLNUITransformTask.h"
#import "MLNUIKitHeader.h"

@implementation MLNUITransformTask

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
        if ([self.target mln_isConvertible]) {
            MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self.target mln_luaCore]);
            [instance pushAnimation:self];
        }
    }
}

- (void)doTask
{
    self.target.transform = self.transform;
}

@end
