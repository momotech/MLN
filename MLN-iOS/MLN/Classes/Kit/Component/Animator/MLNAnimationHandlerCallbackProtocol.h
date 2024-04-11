//
//  MLNAnimationHandlerCallbackProtocol.h
//  MLN
//
//  Created by MoMo on 2019/5/21.
//

#ifndef MLNAnimationHandlerCallbackProtocol_h
#define MLNAnimationHandlerCallbackProtocol_h

#import <UIKit/UIKit.h>

@protocol MLNAnimationHandlerCallbackProtocol <NSObject>

- (void)doAnimationFrame:(NSTimeInterval)frameTime;

@end

#endif /* MLNAnimationHandlerCallbackProtocol_h */
