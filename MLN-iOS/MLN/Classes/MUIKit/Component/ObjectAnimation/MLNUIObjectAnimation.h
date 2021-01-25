//
//  MLNUIObjectAnimation.h
//  MLN
//
//  Created by MOMO on 2020/6/8.
//


#import "MLNUIEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MLAValueAnimation;
@interface MLNUIObjectAnimation : NSObject <MLNUIEntityExportProtocol>

- (MLAValueAnimation *)mlnui_rawAnimation;

@end

NS_ASSUME_NONNULL_END
