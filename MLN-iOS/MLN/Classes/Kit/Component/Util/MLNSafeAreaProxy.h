//
//  MLNNavigationBarObserver.h
//  MLN
//
//  Created by tamer on 2019/12/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNSafeAreaProxy : NSObject

@property (nonatomic, weak, readonly) UINavigationBar *navigationBar;
@property (nonatomic, weak, readonly) UIViewController *viewController;

- (instancetype)initWithNavigationBar:(UINavigationBar *)navigationBar viewController:(UIViewController *)viewController;

- (void)safeAreaTopDidChanged:(void(^)(CGFloat safeAreaTop))callback;

- (CGFloat)safeAreaTop;
- (CGFloat)safeAreaBottom;
- (CGFloat)safeAreaLeft;
- (CGFloat)safeAreaRight;

@end

NS_ASSUME_NONNULL_END
