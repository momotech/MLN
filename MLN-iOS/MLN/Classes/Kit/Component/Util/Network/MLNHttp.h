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
@property (nonatomic, copy) NSString *baseUrlString;

/**
 强关联对象，可以为任意值，也可以为空
 */
@property (nonatomic, strong) id strongAssociatedObject;

/**
 弱关联对象，可以为任意值，也可以为空
 */
@property (nonatomic, weak) id weakAssociatedObject;

- (void)mln_download:(NSString *)urlString params:(NSDictionary *)params progressHandler:(void(^)(float progress, float total))progressHandler completionHandler:(void(^)(BOOL success, NSDictionary *respInfo, id respData, NSDictionary *errorInfo))completionHandler;

@end

NS_ASSUME_NONNULL_END
