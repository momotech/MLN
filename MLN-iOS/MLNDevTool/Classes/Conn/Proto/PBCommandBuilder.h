//
//  PBCommandBuilder.h
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import <UIKit/UIKit.h>
#import "PbbaseCommand.pbobjc.h"
#import "PbdeviceCommand.pbobjc.h"
#import "PbupdateCommand.pbobjc.h"
#import "PbentryFileCommand.pbobjc.h"
#import "PblogCommand.pbobjc.h"
#import "PberrorCommand.pbobjc.h"
#import "PbcloseCommand.pbobjc.h"
#import "PbreloadCommand.pbobjc.h"
#import "PbpingCommand.pbobjc.h"
#import "PbpongCommand.pbobjc.h"
#import "PbremoveCommand.pbobjc.h"
#import "PbrenameCommand.pbobjc.h"
#import "PbmoveCommand.pbobjc.h"
#import "PbcreateCommand.pbobjc.h"
#import "PbcoverageSummaryCommand.pbobjc.h"
#import "PbdetailReportCommand.pbobjc.h"
#import "PbgenerateReportCommand.pbobjc.h"

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
