//
//  MLNUISafeAreaViewProtocol.h
//  MLNUI
//
//  Created by MoMo on 2019/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    MLNUISafeAreaClose = 0,
    MLNUISafeAreaLeft = 1,
    MLNUISafeAreaTop = 2,
    MLNUISafeAreaRight = 4,
    MLNUISafeAreaBottom = 8
} MLNUISafeArea;

@protocol MLNUISafeAreaViewProtocol <NSObject>

- (CGRect)frame;
- (void)updateSafeAreaInsets:(UIEdgeInsets)safeAreaInsets;

@end

NS_ASSUME_NONNULL_END
