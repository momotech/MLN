/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.codec;

import com.immomo.luanative.codec.proto.PackageConst;
import com.immomo.luanative.codec.protobuf.*;

/**
 * The type Pb command convert.
 */
public class PBCommandConvert {

    /**
     * Convert from byte [ ].
     *
     * @param obj the obj
     * @return the byte [ ]
     */
    public static byte[] convertFrom(Object obj) {
        if (obj instanceof com.google.protobuf.GeneratedMessageLite) {
            return ((com.google.protobuf.GeneratedMessageLite)obj).toByteArray();
        }
        return null;
    }

    /**
     * Gets body type.
     *
     * @param obj the obj
     * @return the body type
     */
    public static int getBodyType(Object obj) {
        PBBaseCommand.pbbasecommand baseCmd = null;
        if (obj instanceof PBDeviceCommand.pbdevicecommand) {
            baseCmd = ((PBDeviceCommand.pbdevicecommand)obj).getBasecommand();
        } else if (obj instanceof PBUpdateCommand.pbupdatecommand) {
            baseCmd = ((PBUpdateCommand.pbupdatecommand)obj).getBasecommand();
        } else if (obj instanceof PBEntryFileCommand.pbentryfilecommand) {
            baseCmd = ((PBEntryFileCommand.pbentryfilecommand)obj).getBasecommand();
        } else if (obj instanceof PBReloadCommand.pbreloadcommand) {
            baseCmd = ((PBReloadCommand.pbreloadcommand)obj).getBasecommand();
        } else if (obj instanceof PBCloseCommand.pbclosecommand) {
            baseCmd = ((PBCloseCommand.pbclosecommand)obj).getBasecommand();
        } else if (obj instanceof PBLogCommand.pblogcommand) {
            baseCmd = ((PBLogCommand.pblogcommand)obj).getBasecommand();
        } else if (obj instanceof PBErrorCommand.pberrorcommand) {
            baseCmd = ((PBErrorCommand.pberrorcommand)obj).getBasecommand();
        } else if (obj instanceof PBRenameCommand.pbrenamecommand) {
            baseCmd = ((PBRenameCommand.pbrenamecommand)obj).getBasecommand();
        } else if (obj instanceof PBMoveCommand.pbmovecommand) {
            baseCmd = ((PBMoveCommand.pbmovecommand)obj).getBasecommand();
        } else if (obj instanceof PBRemoveCommand.pbremovecommand) {
            baseCmd = ((PBRemoveCommand.pbremovecommand)obj).getBasecommand();
        } else if (obj instanceof PBCreateCommand.pbcreatecommand) {
            baseCmd = ((PBCreateCommand.pbcreatecommand)obj).getBasecommand();
        } else if (obj instanceof PBCoverageSummaryCommand.pbcoveragesummarycommand) {
            baseCmd = ((PBCoverageSummaryCommand.pbcoveragesummarycommand) obj).getBasecommand();
        } else if (obj instanceof PBCoverageDetailCommand.pbcoveragedetailcommand) {
            baseCmd = ((PBCoverageDetailCommand.pbcoveragedetailcommand) obj).getBasecommand();
        } else if (obj instanceof PBIPAddressCommand.pbipaddresscommand) {
            baseCmd = ((PBIPAddressCommand.pbipaddresscommand) obj).getBasecommand();
        }

        if (baseCmd != null) {
            return baseCmd.getInstruction();
        }
        return -1;
    }

    /**
     * Gets package type.
     *
     * @param obj the obj
     * @return the package type
     */
    public static byte getPackageType(Object obj) {
        if (obj instanceof PBPingCommand.pbpingcommand) {
            return PackageConst.MAGIC_PING;
        } else if (obj instanceof PBPongCommand.pbpongcommand) {
            return PackageConst.MAGIC_PONG;
        }
        return PackageConst.MAGIC_MESSAGE;
    }

}