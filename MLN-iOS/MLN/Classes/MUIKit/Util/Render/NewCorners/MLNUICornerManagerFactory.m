//
//  MLNUICornerManagerFactory.m
//
//
//  Created by MoMo on 2019/5/26.
//

#import "MLNUICornerManagerFactory.h"
#import "MLNUICornerLayerHandler.h"
#import "MLNUICornerMaskLayerHndler.h"
#import "MLNUICornerMaskViewHandler.h"

@implementation MLNUICornerManagerFactory

+ (id<MLNUICornerHandlerPotocol>)handlerWithType:(MLNUICornerMode)cornerModel targetView:(UIView *)targetView
{
    switch (cornerModel) {
        case MLNUICornerLayerMode:
            return [[MLNUICornerLayerHandler alloc] initWithTargetView:targetView];
            break;
        case MLNUICornerMaskLayerMode:
            return [[MLNUICornerMaskLayerHndler alloc] initWithTargetView:targetView];
            break;
        case MLNUICornerMaskImageViewMode:
            return [[MLNUICornerMaskViewHandler alloc] initWithTargetView:targetView];
            break;
        default:
            break;
    }
    return nil;
}

@end
