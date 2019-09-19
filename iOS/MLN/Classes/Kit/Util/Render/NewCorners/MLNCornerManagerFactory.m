//
//  MLNCornerManagerFactory.m
//
//
//  Created by MoMo on 2019/5/26.
//

#import "MLNCornerManagerFactory.h"
#import "MLNCornerLayerHandler.h"
#import "MLNCornerMaskLayerHndler.h"
#import "MLNCornerMaskViewHandler.h"

@implementation MLNCornerManagerFactory

+ (id<MLNCornerHandlerPotocol>)handlerWithType:(MLNCornerMode)cornerModel targetView:(UIView *)targetView
{
    switch (cornerModel) {
        case MLNCornerLayerMode:
            return [[MLNCornerLayerHandler alloc] initWithTargetView:targetView];
            break;
        case MLNCornerMaskLayerMode:
            return [[MLNCornerMaskLayerHndler alloc] initWithTargetView:targetView];
            break;
        case MLNCornerMaskImageViewMode:
            return [[MLNCornerMaskViewHandler alloc] initWithTargetView:targetView];
            break;
        default:
            break;
    }
    return nil;
}

@end
