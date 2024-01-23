//
//  MLNDependenceGroup.h
//  MLN
//
//  Created by xue.yunqiang on 2022/5/5.
//

#import <Foundation/Foundation.h>
#import "MLNDependenceWidget.h"

typedef NS_ENUM(NSUInteger, MLNDependenceGroupStatus) {
    MLNDependenceGroupStatusNone,
    MLNDependenceGroupStatusUnzip,
    MLNDependenceGroupStatusDownloading,
    MLNDependenceGroupStatusFinished,
};

NS_ASSUME_NONNULL_BEGIN

@interface MLNDependenceGroup : NSObject

/// Group ID
@property(nonatomic, copy, readonly) NSString *gid;

/// Group 名字
@property(nonatomic, copy) NSString *name;

/// Group 唯一标识符
@property(nonatomic, copy) NSString *identifier;

/// Group version
@property(nonatomic, copy) NSString *version;

/// Group 状态
@property(nonatomic, assign) MLNDependenceGroupStatus status;

/// 检验失败重试次数
@property(nonatomic, assign) int retryCount;

/// MLN project 直接依赖的 widget
/// @discussion  直接依赖的 widget 需要 version
@property(nonatomic, strong) NSArray<MLNDependenceWidget*> *directWidgets;

/// MLN project 间接依赖的 widget
/// @discussion  间接依赖的 widget 不需要 version
@property(nonatomic, strong) NSArray<MLNDependenceWidget*> *dependenceWidgets;

@property(nonatomic, strong, readonly) NSMutableDictionary<NSString*,MLNDependenceWidget*> *allMap;

@end

NS_ASSUME_NONNULL_END
