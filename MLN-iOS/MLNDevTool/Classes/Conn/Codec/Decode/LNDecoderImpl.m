//
//  MLNDecoderImpl.m
//  MLNDebugger
//
//  Created by MoMo on 2019/7/2.
//

#import "LNDecoderImpl.h"
#import "PBCommandBuilder.h"

@implementation LNDecoderImpl

- (id)decode:(NSData *)data type:(int)type
{
    Class clazz = nil;
    switch (type) {
        case pbbasecommand_InstructionType_EntryFile: {
            clazz = pbentryfilecommand.class;
            break;
        }
        case pbbasecommand_InstructionType_Update: {
            clazz = pbupdatecommand.class;
            break;
        }
        case pbbasecommand_InstructionType_Reload: {
            clazz = pbreloadcommand.class;
            break;
        }
        case pbbasecommand_InstructionType_Device: {
            clazz = pbdevicecommand.class;
            break;
        }
        case pbbasecommand_InstructionType_Close: {
            clazz = pbclosecommand.class;
            break;
        }
        case pbbasecommand_InstructionType_Log: {
            clazz = pblogcommand.class;
            break;
        }
        case pbbasecommand_InstructionType_Error: {
            clazz = pberrorcommand.class;
            break;
        }
        case pbbasecommand_InstructionType_Ping: {
            clazz = pbpingcommand.class;
            break;
        }
        case pbbasecommand_InstructionType_Pong: {
            clazz = pbpongcommand.class;
            break;
        }
        case pbbasecommand_InstructionType_Rename: {
            clazz = pbrenamecommand.class;
            break;
        }
        case pbbasecommand_InstructionType_Remove: {
            clazz = pbremovecommand.class;
            break;
        }
        case pbbasecommand_InstructionType_Move: {
            clazz = pbmovecommand.class;
            break;
        }
        case pbbasecommand_InstructionType_Create: {
            clazz = pbcreatecommand.class;
            break;
        }
        case pbbasecommand_InstructionType_Coveragesummary: {
            clazz = pbcoveragesummarycommand.class;
            break;
        }
        case pbbasecommand_InstructionType_CoverageDetail: {
            clazz = pbcoveragedetailcommand.class;
            break;
        }
        case pbbasecommand_InstructionType_CoverageVisual: {
            clazz = pbcoveragevisualcommand.class;
            break;
        }
        default:
            break;
    }
    if (clazz) {
        return [PBCommandBuilder buildCmd:clazz data:data];
    }
    return nil;
}

@end
