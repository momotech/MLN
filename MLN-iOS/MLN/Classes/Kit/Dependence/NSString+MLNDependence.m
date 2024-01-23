//
//  NSString+MLNDependence.m
//  MLN
//
//  Created by xue.yunqiang on 2022/5/5.
//

#import "NSString+MLNDependence.h"

@implementation NSString (MLNDependence)

- (NSDictionary *)dictionaryWithContentFile {
    NSData *data = [NSData dataWithContentsOfFile:self];
    if (data && [data length]) {
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    }
    return nil;
}

@end
