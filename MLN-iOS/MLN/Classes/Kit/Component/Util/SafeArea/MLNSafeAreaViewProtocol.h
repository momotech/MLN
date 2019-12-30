//
//  MLNSafeAreaViewProtocol.h
//  MLN
//
//  Created by MoMo on 2019/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    MLNSafeAreaClose = 0,
    MLNSafeAreaLeft = 1,
    MLNSafeAreaTop = 2,
    MLNSafeAreaRight = 4,
    MLNSafeAreaBottom = 8
} MLNSafeArea;

@protocol MLNSafeAreaViewProtocol <NSObject>

- (CGRect)frame;
- (void)updateSafeAreaInsets:(UIEdgeInsets)safeAreaInsets;

@end

NS_ASSUME_NONNULL_END
