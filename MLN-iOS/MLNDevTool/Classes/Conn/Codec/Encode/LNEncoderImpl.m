//
//  MLNEncoderImpl.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import "LNEncoderImpl.h"
#import "NSMutableData+LuaNative.h"
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
#import "PbcoverageSummaryCommand.pbobjc.h"
#import "PbgenerateReportCommand.pbobjc.h"
#import "PbdetailReportCommand.pbobjc.h"

@implementation LNEncoderImpl

- (NSData *)encode:(id)msg
{
    NSMutableData *data = [NSMutableData data];
    pbbasecommand_InstructionType type = -1;
    if ([msg isKindOfClass:[pbdevicecommand class]]) {
        type = pbbasecommand_InstructionType_Device;
    } else if ([msg isKindOfClass:[pblogcommand class]]){
        type = pbbasecommand_InstructionType_Log;
    } else if ([msg isKindOfClass:[pberrorcommand class]]){
        type = pbbasecommand_InstructionType_Error;
    } else if ([msg isKindOfClass:[pbreloadcommand class]]){
        type = pbbasecommand_InstructionType_Reload;
    } else if ([msg isKindOfClass:[pbentryfilecommand class]]){
        type = pbbasecommand_InstructionType_EntryFile;
    } else if ([msg isKindOfClass:[pbupdatecommand class]]){
        type = pbbasecommand_InstructionType_Update;
    } else if ([msg isKindOfClass:[pbclosecommand class]]){
        type = pbbasecommand_InstructionType_Close;
    } else if ([msg isKindOfClass:[pbcoveragesummarycommand class]]) {
        type = pbbasecommand_InstructionType_Coveragesummary;
    } else if ([msg isKindOfClass:[pbcoveragedetailcommand class]]) {
        type = pbbasecommand_InstructionType_CoverageDetail;
    } else if ([msg isKindOfClass:[pbcoveragevisualcommand class]]) {
        type = pbbasecommand_InstructionType_CoverageVisual;
    }  else if ([msg isKindOfClass:[pbpingcommand class]]) {
        [data appendChar:0x02];
        [data appendInt32:[(pbpingcommand *)msg ip]];
        [data appendInt16:[(pbpingcommand *)msg port]];
        [data appendByte:0x04];
        return data.copy;
    } else if ([msg isKindOfClass:[pbpongcommand class]]){
        [data appendChar:0x03];
        [data appendInt32:[(pbpongcommand *)msg ip]];
        [data appendInt16:[(pbpongcommand *)msg port]];
        [data appendByte:0x04];
        return data.copy;
    }
    if (type == -1) {
        return nil;
    }
    [data appendChar:0x01];
    [data appendInt32:type];
    NSData *body = [(pbdevicecommand *)msg data];
    int bl = (int)body.length;
    [data appendInt32:bl];
    [data appendData:body];
    [data appendByte:0x04];
    return data.copy;
}


@end
