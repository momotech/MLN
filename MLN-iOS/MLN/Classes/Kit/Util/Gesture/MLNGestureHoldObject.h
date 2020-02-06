//
//  MLNGestureHoldObject.h
//  AFNetworking
//
//  Created by MOMO on 2020/2/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNGestureHoldObject : NSObject

@property (nonatomic, weak) UIGestureRecognizer *mln_gesture;

- (instancetype)initWithGesture:(UIGestureRecognizer *)mln_gesture;

@end


NS_ASSUME_NONNULL_END
