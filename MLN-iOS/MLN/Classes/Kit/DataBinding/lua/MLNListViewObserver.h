//
//  MLNListViewObserver.h
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/5.
//

#import "MLNKVOObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNListViewObserver : MLNKVOObserver

@property (nonatomic, strong, readonly) UIView *listView;

+ (instancetype)observerWithListView:(UIView *)listView keyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
