//
//  ArgoListViewObserver.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/30.
//

#import "ArgoObserverBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArgoListViewObserver : ArgoObserverBase

@property (nonatomic, strong, readonly) UIView *listView;

+ (instancetype)observerWithListView:(UIView *)listView keyPath:(NSString *)keyPath callback:(nullable ArgoBlockChange)callback;

@end

NS_ASSUME_NONNULL_END
