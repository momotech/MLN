//
//  MLNRecordLogProtocol.h
//  MLN
//
//  Created by xue.yunqiang on 2022/5/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLNRecordLogProtocol <NSObject>
@optional
-(void)recorderLog:(NSString *)log;
@end

NS_ASSUME_NONNULL_END
