//
//  PBCommandBuilder.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import "PBCommandBuilder.h"
#import "UIDevice+HotReload.h"

@implementation PBCommandBuilder

+ (pbbasecommand *)buildBaseCmd:(pbbasecommand_InstructionType)type
{
    pbbasecommand *baseCommand = [[pbbasecommand alloc] init];
    baseCommand.ip = [[UIDevice currentDevice] getIPv4Address];
    baseCommand.version = 1.0;
    baseCommand.port = 8174;
    baseCommand.osType = @"iOS";
    baseCommand.serialNumber = [[UIDevice currentDevice] getUUID];
    baseCommand.instruction = type;
    baseCommand.timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    return baseCommand;
}

+ (pbdevicecommand *)buildDeviceCmd
{
    pbdevicecommand *device = [[pbdevicecommand alloc] init];
    device.basecommand = [self buildBaseCmd:pbbasecommand_InstructionType_Device];
    device.model = [[UIDevice currentDevice] getModel];
    device.name = [UIDevice currentDevice].name;
    return device;
}

+ (pblogcommand *)buildLogCmd:(NSString *)log entryFilePath:(NSString *)entryFilePath
{
    pblogcommand *logCmd = [[pblogcommand alloc] init];
    logCmd.basecommand = [self buildBaseCmd:pbbasecommand_InstructionType_Log];
    logCmd.log = log;
    logCmd.entryFilePath = entryFilePath;
    return logCmd;
}

+ (pberrorcommand *)buildErrorCmd:(NSString *)error entryFilePath:(NSString *)entryFilePath
{
    pberrorcommand *errCmd = [[pberrorcommand alloc] init];
    errCmd.basecommand = [self buildBaseCmd:pbbasecommand_InstructionType_Error];
    errCmd.error = error;
    errCmd.entryFilePath = entryFilePath;
    return errCmd;
}

+ (pbpongcommand *)buildPongCmd:(NSString *)ip port:(int)port
{
    pbpongcommand *cmd = [[pbpongcommand alloc] init];
    cmd.ip = 12313;
    cmd.port = (int32_t)port;
    return cmd;
}

+ (pbpingcommand *)buildPingCmd
{
    pbpingcommand *cmd = [[pbpingcommand alloc] init];
    cmd.ip = 131213;
    cmd.port = (int32_t)8888;
    return cmd;
}

+ (GPBMessage *)buildCmd:(Class)clazz data:(NSData *)data
{
    return [clazz parseFromData:data error:NULL];
}

+ (pbbasecommand *)buildBaseCmdNotUUID:(pbbasecommand_InstructionType)type
{
    pbbasecommand *baseCommand = [[pbbasecommand alloc] init];
    baseCommand.ip = [[UIDevice currentDevice] getIPv4Address];
    baseCommand.version = 1.0;
    baseCommand.port = 8174;
    baseCommand.osType = @"iOS";
    baseCommand.serialNumber = [[UIDevice currentDevice] getSerialNumber];
    baseCommand.instruction = type;
    baseCommand.timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    return baseCommand;
}

+ (pbdevicecommand *)buildDeviceCmdNotUUID
{
    pbdevicecommand *device = [[pbdevicecommand alloc] init];
    device.basecommand = [self buildBaseCmdNotUUID:pbbasecommand_InstructionType_Device];
    device.model = [[UIDevice currentDevice] getModel];
    device.name = [UIDevice currentDevice].name;
    return device;
}

+ (pblogcommand *)buildLogCmdNotUUID:(NSString *)log entryFilePath:(NSString *)entryFilePath
{
    pblogcommand *logCmd = [[pblogcommand alloc] init];
    logCmd.basecommand = [self buildBaseCmdNotUUID:pbbasecommand_InstructionType_Log];
    logCmd.log = log;
    logCmd.entryFilePath = entryFilePath;
    return logCmd;
}

+ (pberrorcommand *)buildErrorCmdNotUUID:(NSString *)error entryFilePath:(NSString *)entryFilePath
{
    pberrorcommand *errCmd = [[pberrorcommand alloc] init];
    errCmd.basecommand = [self buildBaseCmdNotUUID:pbbasecommand_InstructionType_Error];
    errCmd.error = error;
    errCmd.entryFilePath = entryFilePath;
    return errCmd;
}

+ (pbcoveragesummarycommand *)buildCoverageSummaryCmd:(NSData *)fileData filePath:(NSString *)filePath {
    pbcoveragesummarycommand *covCmd = [[pbcoveragesummarycommand alloc] init];
    covCmd.basecommand = [self buildBaseCmdNotUUID:pbbasecommand_InstructionType_Coveragesummary];
    covCmd.fileData = fileData;
    covCmd.filePath = filePath;
    return covCmd;
}

+ (pbcoveragedetailcommand *)buildCoverageDetailCmd:(NSData *)fileData filePath:(NSString *)filePath {
    pbcoveragedetailcommand *covCmd = [[pbcoveragedetailcommand alloc] init];
    covCmd.basecommand = [self buildBaseCmdNotUUID:pbbasecommand_InstructionType_CoverageDetail];
    covCmd.fileData = fileData;
    covCmd.filePath = filePath;
    return covCmd;
}

+ (pbcoveragevisualcommand *)buildCoverageVisualCmd {
    pbcoveragevisualcommand *covCmd = [[pbcoveragevisualcommand alloc] init];
    covCmd.basecommand = [self buildBaseCmdNotUUID:pbbasecommand_InstructionType_CoverageVisual];
    return covCmd;
}


@end
