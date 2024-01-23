//
//  MLNLuaViewDefaultLogUpload.m
//  MLN
//
//  Created by xue.yunqiang on 2022/2/7.
//

#import "MLNLuaViewDefaultLogUpload.h"
#import "MLNLuaViewLogUploadProtocol.h"

@implementation MLNLuaViewDefaultLogUpload
- (void)logUploadWithDic:(NSDictionary *)params {
    NSString *infoStr = @"";
    for (NSString *key in params.allKeys) {
        infoStr = [infoStr stringByAppendingFormat:@"%@:%@\n",key,params[key]];
    }
    NSLog(@"Default LogUpload Error Log:\n%@",infoStr);
}
@end
