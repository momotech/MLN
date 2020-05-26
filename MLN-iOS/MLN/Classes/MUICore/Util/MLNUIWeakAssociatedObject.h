//
//  MLNUIWeakAssociatedObject.h
//  MLNUI
//
//  Created by MoMo on 2019/8/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 处理分类中弱引用问题的工具类。
 */
@interface MLNUIWeakAssociatedObject : NSObject

/**
 关联对象
 */
@property (nonatomic, weak, readonly) id associatedObject;

/**
 创建弱引用关联工具实例

 @param associatedObject 被关联对象
 @return 弱引用关联工具实例
 */
+ (instancetype)weakAssociatedObject:(id)associatedObject;

/**
 初始化弱引用关联工具实例

 @param associatedObject 被关联对象
 @return 弱引用关联工具实例
 */
- (instancetype)initWithAssociatedObject:(id)associatedObject;

/**
 更新被关联对象

 @param associatedObject 被关联对象
 */
- (void)updateAssociatedObject:(id)associatedObject;

@end

NS_ASSUME_NONNULL_END
