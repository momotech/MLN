//
//  MLNCornerManagerFactory.h
//
//
//  Created by MoMo on 2019/5/26.
//

#import <Foundation/Foundation.h>
#import "MLNViewConst.h"
#import "MLNCornerHandlerPotocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface MLNCornerManagerFactory : NSObject

+ (id<MLNCornerHandlerPotocol>)handlerWithType:(MLNCornerMode)cornerModel
                                    targetView:(UIView *)targetView;

@end

NS_ASSUME_NONNULL_END
