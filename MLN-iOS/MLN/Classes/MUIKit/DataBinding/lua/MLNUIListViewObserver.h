//
//  MLNUIListViewObserver.h
// MLNUI
//
//  Created by Dai Dongpeng on 2020/3/5.
//

#import "MLNUIKVOObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIListViewObserver : MLNUIKVOObserver

@property (nonatomic, strong, readonly) UIView *listView;

+ (instancetype)observerWithListView:(UIView *)listView keyPath:(NSString *)keyPath callback:(MLNUIKVOCallback)callback;

@end

NS_ASSUME_NONNULL_END
