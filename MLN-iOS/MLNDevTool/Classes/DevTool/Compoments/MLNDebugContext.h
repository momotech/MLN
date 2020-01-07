//
//  MLNDebugContext.h
//  MLNDevTool
//
//  Created by MOMO on 2020/1/6.
//

#import <Foundation/Foundation.h>
#import <MLN/MLNKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNDebugContext : NSObject<MLNGlobalFuncExportProtocol>

+ (MLNDebugContext *)sharedContext;
+ (NSBundle *)debugBundle;

@property (nonatomic, strong) NSString *ipAddress;
@property (nonatomic, assign) NSInteger port;

@end

NS_ASSUME_NONNULL_END
