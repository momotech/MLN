//
//  MLNUICornerManagerFactory.h
//
//
//  Created by MoMo on 2019/5/26.
//

#import <Foundation/Foundation.h>
#import "MLNUIViewConst.h"
#import "MLNUICornerHandlerPotocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface MLNUICornerManagerFactory : NSObject

+ (id<MLNUICornerHandlerPotocol>)handlerWithType:(MLNUICornerMode)cornerModel
                                    targetView:(UIView *)targetView;

@end

NS_ASSUME_NONNULL_END
