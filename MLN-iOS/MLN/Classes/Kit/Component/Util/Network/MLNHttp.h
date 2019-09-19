//
//  MLNHttp.h
//  MLN
//
//  Created by MoMo on 2019/8/3.
//

#import <Foundation/Foundation.h>
#import "MLNEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNHttp : NSObject <MLNEntityExportProtocol>

/**
 网络请求的根地址
 */
@property (nonatomic, copy, readonly) NSString *baseUrlString;

/**
 添加缓存策略需要过滤的参数Key
 */
@property (nonatomic, strong, readonly) NSSet *CachePolicyFilterKeys;

/**
 强关联对象，可以为任意值，也可以为空
 */
@property (nonatomic, strong) id strongAssociatedObject;

/**
 弱关联对象，可以为任意值，也可以为空
 */
@property (nonatomic, strong) id weakAssociatedObject;

@end

NS_ASSUME_NONNULL_END
