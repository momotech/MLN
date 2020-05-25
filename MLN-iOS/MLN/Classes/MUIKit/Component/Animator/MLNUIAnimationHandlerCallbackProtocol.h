//
//  MLNUIAnimationHandlerCallbackProtocol.h
//  MLNUI
//
//  Created by MoMo on 2019/5/21.
//

#ifndef MLNUIAnimationHandlerCallbackProtocol_h
#define MLNUIAnimationHandlerCallbackProtocol_h

#import <UIKit/UIKit.h>

@protocol MLNUIAnimationHandlerCallbackProtocol <NSObject>

- (void)doAnimationFrame:(NSTimeInterval)frameTime;

@end

#endif /* MLNUIAnimationHandlerCallbackProtocol_h */
