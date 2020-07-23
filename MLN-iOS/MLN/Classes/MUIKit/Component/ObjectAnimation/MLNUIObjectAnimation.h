//
//  MLNUIObjectAnimation.h
//  MLN
//
//  Created by MOMO on 2020/6/8.
//

#import "MLAAnimation.h"
#import "MLNUIEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIObjectAnimation : NSObject <MLNUIEntityExportProtocol>

- (MLAValueAnimation *)mlnui_rawAnimation;

@end

NS_ASSUME_NONNULL_END
