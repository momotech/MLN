//
//  MLNZipArchive.h
//  MLNDevTool
//
//  Created by MoMo on 2019/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNZipArchive : NSObject

+ (BOOL)unzipData:(NSData *)data toDirectory:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
