/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.codec;

import android.annotation.SuppressLint;
import android.os.Build;

import com.google.protobuf.ByteString;
import com.immomo.luanative.codec.proto.PackageConst;
import com.immomo.luanative.codec.protobuf.PBBaseCommand;
import com.immomo.luanative.codec.protobuf.PBCloseCommand;
import com.immomo.luanative.codec.protobuf.PBCoverageDetailCommand;
import com.immomo.luanative.codec.protobuf.PBCoverageSummaryCommand;
import com.immomo.luanative.codec.protobuf.PBDeviceCommand;
import com.immomo.luanative.codec.protobuf.PBEntryFileCommand;
import com.immomo.luanative.codec.protobuf.PBErrorCommand;
import com.immomo.luanative.codec.protobuf.PBLogCommand;
import com.immomo.luanative.codec.protobuf.PBPingCommand;
import com.immomo.luanative.codec.protobuf.PBPongCommand;
import com.immomo.luanative.codec.protobuf.PBReloadCommand;
import com.immomo.luanative.codec.protobuf.PBUpdateCommand;

public class PBCommandFactory {
    public static String Serial = Build.UNKNOWN;

    public static Object getEntryFileCommand(String entryFilePath) {
        PBEntryFileCommand.pbentryfilecommand.Builder builder = PBEntryFileCommand.pbentryfilecommand.newBuilder();
        builder.setEntryFilePath(entryFilePath);
        builder.setBasecommand(getBaseCommand(PackageConst.TYPE_ENTRY_FILE));
        return builder.build();
    }

    public static Object getUpdateCommand(String filePath, String fileData) {
        PBUpdateCommand.pbupdatecommand.Builder builder = PBUpdateCommand.pbupdatecommand.newBuilder();
        builder.setFilePath(filePath);
        builder.setFileData(ByteString.copyFromUtf8(fileData));
        builder.setBasecommand(getBaseCommand(PackageConst.TYPE_UPDATE));
        return builder.build();
    }

    public static Object getReloadCommand() {
        PBReloadCommand.pbreloadcommand.Builder builder = PBReloadCommand.pbreloadcommand.newBuilder();
        builder.setBasecommand(getBaseCommand(PackageConst.TYPE_RELOAD));
        return builder.build();
    }

    public static Object getCloseCommand() {
        PBCloseCommand.pbclosecommand.Builder builder = PBCloseCommand.pbclosecommand.newBuilder();
        builder.setBasecommand(getBaseCommand(PackageConst.TYPE_CLOSE));
        return builder.build();
    }

    public static Object getDeviceCommand() {
        PBDeviceCommand.pbdevicecommand.Builder builder = PBDeviceCommand.pbdevicecommand.newBuilder();
        builder.setBasecommand(getBaseCommand(PackageConst.TYPE_DEVICE));
        builder.setModel(android.os.Build.MODEL);
        builder.setName(android.os.Build.MODEL);
        return builder.build();
    }

    public static Object getLogCommand(String log, String entryFilePath) {
        PBLogCommand.pblogcommand.Builder builder = PBLogCommand.pblogcommand.newBuilder();
        builder.setBasecommand(getBaseCommand(PackageConst.TYPE_LOG));
        builder.setLog(log);
        builder.setEntryFilePath(entryFilePath);
        return builder.build();
    }

    public static Object getErrorCommand(String error, String entryFilePath) {
        PBErrorCommand.pberrorcommand.Builder builder = PBErrorCommand.pberrorcommand.newBuilder();
        builder.setBasecommand(getBaseCommand(PackageConst.TYPE_ERROR));
        builder.setError(error);
        builder.setEntryFilePath(entryFilePath);
        return builder.build();
    }

    public static Object getPingCommand(String ip, int port) {
        PBPingCommand.pbpingcommand.Builder builder = PBPingCommand.pbpingcommand.newBuilder();
        builder.setIp(1111);
        builder.setPort(port);
        return builder.build();
    }

    public static Object getPongCommand(String ip, int port) {
        PBPongCommand.pbpongcommand.Builder builder = PBPongCommand.pbpongcommand.newBuilder();
        builder.setIp(1111);
        builder.setPort(port);
        return builder.build();
    }

    @SuppressLint("MissingPermission")
    public static PBBaseCommand.pbbasecommand getBaseCommand(int code) {
        PBBaseCommand.pbbasecommand.Builder builder = PBBaseCommand.pbbasecommand.newBuilder();
        builder.setSerialNumber(Serial);
        builder.setOsType("Android");
        builder.setVersion(1);
        builder.setInstruction(code);
        builder.setTimestamp(System.currentTimeMillis());
        return builder.build();
    }

    public static PBCoverageSummaryCommand.pbcoveragesummarycommand getSummaryCommand(String file, byte[] data) {
        return PBCoverageSummaryCommand.pbcoveragesummarycommand.newBuilder()
                .setFilePath(file)
                .setFileData(ByteString.copyFrom(data))
                .setBasecommand(getBaseCommand(PackageConst.TYPE_CSUMMER))
                .build();
    }

    public static PBCoverageDetailCommand.pbcoveragedetailcommand getDetailCommand(String file, byte[] data) {
        return PBCoverageDetailCommand.pbcoveragedetailcommand.newBuilder()
                .setFilePath(file)
                .setFileData(ByteString.copyFrom(data))
                .setBasecommand(getBaseCommand(PackageConst.TYPE_CDETAIL))
                .build();
    }
}