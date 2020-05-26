//
//  MLNUISafeAreaProxy.h
//  MLNUI
//
//  Created by MoMo on 2019/12/19.
//

#import <Foundation/Foundation.h>
#import "MLNUISafeAreaViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class MLNUISafeAreaAdapter;
@interface MLNUISafeAreaProxy : NSObject

@property (nonatomic, weak) UIView<MLNUISafeAreaViewProtocol> *safeAreaView;
@property (nonatomic, weak, readonly) UINavigationBar *navigationBar;
@property (nonatomic, weak, readonly) UIViewController *viewController;

@property (nonatomic, assign) MLNUISafeArea safeArea;
@property (nonatomic, strong) MLNUISafeAreaAdapter *adapter;

- (instancetype)initWithSafeAreaView:(UIView<MLNUISafeAreaViewProtocol> *)safeAreaView navigationBar:(UINavigationBar *)navigationBar viewController:(UIViewController *)viewController;

- (CGFloat)safeAreaTop;
- (CGFloat)safeAreaBottom;
- (CGFloat)safeAreaLeft;
- (CGFloat)safeAreaRight;

- (void)detachSafeAreaView:(UIView<MLNUISafeAreaViewProtocol> *)safeAreaView;

@end

NS_ASSUME_NONNULL_END
