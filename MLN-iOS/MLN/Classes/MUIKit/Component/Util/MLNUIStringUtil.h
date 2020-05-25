//
//  MLNUIStringUtil.h
//
//
//  Created by MoMo on 2018/10/11.
//

#import <Foundation/Foundation.h>
#import "MLNUIStaticExportProtocol.h"

@interface MLNUIStringUtil : NSObject<MLNUIStaticExportProtocol>

+ (BOOL)constraintString:(NSString *)str specifiedLength:(NSUInteger)maxCount;
+ (NSString *)constrainString:(NSString *)string toMaxLength:(NSUInteger)maxLength;

@end
