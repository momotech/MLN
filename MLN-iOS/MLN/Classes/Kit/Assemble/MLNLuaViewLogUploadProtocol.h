//
//  MLNLuaViewLogUploadProtocol.h
//  MLN
//
//  Created by xue.yunqiang on 2022/1/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLNLuaViewLogUploadProtocol <NSObject>

@required
- (void)logUploadWithDic:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
