package com.immomo.luanative.codec.protobuf;

import com.immomo.luanative.codec.proto.PackageConst;

public class PBMessageFactory {

    public static Object getInstance(int type, byte[] data) throws Exception {
        switch (type) {
            case PackageConst.TYPE_DEVICE: {
                return PBDeviceCommand.pbdevicecommand.parseFrom(data);
            }
            case PackageConst.TYPE_ENTRY_FILE: {
                return PBEntryFileCommand.pbentryfilecommand.parseFrom(data);
            }
            case PackageConst.TYPE_UPDATE: {
                return PBUpdateCommand.pbupdatecommand.parseFrom(data);
            }
            case PackageConst.TYPE_RELOAD: {
                return PBReloadCommand.pbreloadcommand.parseFrom(data);
            }
            case PackageConst.TYPE_CLOSE: {
                return PBCloseCommand.pbclosecommand.parseFrom(data);
            }
            case PackageConst.TYPE_LOG: {
                return PBLogCommand.pblogcommand.parseFrom(data);
            }
            case PackageConst.TYPE_ERROR: {
                return PBErrorCommand.pberrorcommand.parseFrom(data);
            }
            case PackageConst.TYPE_CREATE: {
                return PBCreateCommand.pbcreatecommand.parseFrom(data);
            }
            case PackageConst.TYPE_RENAME: {
                return PBRenameCommand.pbrenamecommand.parseFrom(data);
            }
            case PackageConst.TYPE_MOVE: {
                return PBMoveCommand.pbmovecommand.parseFrom(data);
            }
            case PackageConst.TYPE_REMOVE: {
                return PBRemoveCommand.pbremovecommand.parseFrom(data);
            }
            default: {
                throw new Exception("未知类型的消息");
            }
        }
    }
}
