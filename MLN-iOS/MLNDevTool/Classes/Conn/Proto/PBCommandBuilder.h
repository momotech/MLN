//
//  PBCommandBuilder.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import <UIKit/UIKit.h>
#import <MLNProtobuf.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBCommandBuilder : NSObject

+ (pbbasecommand *)buildBaseCmd:(pbbasecommand_InstructionType)type;
+ (pbdevicecommand *)buildDeviceCmd;
+ (pblogcommand *)buildLogCmd:(NSString *)log entryFilePath:(NSString *)entryFilePath;
+ (pberrorcommand *)buildErrorCmd:(NSString *)error entryFilePath:(NSString *)entryFilePath;
+ (pbpongcommand *)buildPongCmd:(NSString *)ip port:(int)port;
+ (pbpingcommand *)buildPingCmd;

+ (GPBMessage *)buildCmd:(Class)clazz data:(NSData *)data;

+ (pbbasecommand *)buildBaseCmdNotUUID:(pbbasecommand_InstructionType)type;
+ (pbdevicecommand *)buildDeviceCmdNotUUID;
+ (pblogcommand *)buildLogCmdNotUUID:(NSString *)log entryFilePath:(NSString *)entryFilePath;
+ (pberrorcommand *)buildErrorCmdNotUUID:(NSString *)error entryFilePath:(NSString *)entryFilePath;

+ (pbcoveragesummarycommand *)buildCoverageSummaryCmd:(NSData *)fileData filePath:(NSString *)filePath;
+ (pbcoveragedetailcommand *)buildCoverageDetailCmd:(NSData *)fileData filePath:(NSString *)filePath;
+ (pbcoveragevisualcommand *)buildCoverageVisualCmd;

@end

NS_ASSUME_NONNULL_END
