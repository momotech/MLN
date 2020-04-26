//
//  MLNSafeAreaProxy.h
//  MLN
//
//  Created by MoMo on 2019/12/19.
//

#import <Foundation/Foundation.h>
#import "MLNSafeAreaViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNSafeAreaAdapter;
@interface MLNSafeAreaProxy : NSObject

@property (nonatomic, weak) UIView<MLNSafeAreaViewProtocol> *safeAreaView;
@property (nonatomic, weak, readonly) UINavigationBar *navigationBar;
@property (nonatomic, weak, readonly) UIViewController *viewController;

@property (nonatomic, assign) MLNSafeArea safeArea;
@property (nonatomic, strong) MLNSafeAreaAdapter *adapter;

- (instancetype)initWithSafeAreaView:(UIView<MLNSafeAreaViewProtocol> *)safeAreaView navigationBar:(UINavigationBar *)navigationBar viewController:(UIViewController *)viewController;

- (CGFloat)safeAreaTop;
- (CGFloat)safeAreaBottom;
- (CGFloat)safeAreaLeft;
- (CGFloat)safeAreaRight;

- (void)resestSafeAreaInsets;

@end

NS_ASSUME_NONNULL_END
