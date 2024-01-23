//
//  MLNListWhiteDetectLogHandle.h
//  MLN
//
//  Created by xue.yunqiang on 2022/3/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLNListWhiteDetectLogProtocol <NSObject>

@required
- (void)mlnListWhiteDetectLog:(NSDictionary *)logDic;

@end

NS_ASSUME_NONNULL_END
