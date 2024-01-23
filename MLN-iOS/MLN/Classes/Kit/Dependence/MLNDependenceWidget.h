//
//  MLNDependenceWidget.h
//  MLN
//
//  Created by xue.yunqiang on 2022/5/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNDependenceWidget : NSObject

/// widget 唯一标识符
@property(nonatomic, copy, readonly) NSString *wid;
/// widget 名字
@property(nonatomic, copy) NSString *name;
/// widget 版本
@property(nonatomic, copy) NSString *version;
/// widget 大小
@property(nonatomic, strong) NSNumber *size;
/// widget 摘要
@property(nonatomic, copy) NSString *summary;

@end

NS_ASSUME_NONNULL_END
