/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.codec.proto;



//| MAGIC_SOH (1 byte) | MAGIC_SOH (1 byte) | BodyLength (4byte) | ...|


import com.immomo.luanative.codec.protobuf.PBBaseCommand;

/**
 * The type Package const.
 */
public class PackageConst {
    /**
     * The constant MAGIC_MESSAGE.
     */
    public static final byte MAGIC_MESSAGE = (byte)0x01; // 普通消息
    /**
     * The constant MAGIC_PING.
     */
    public static final byte MAGIC_PING = (byte)0x02; // 心跳 ping
    /**
     * The constant MAGIC_PONG.
     */
    public static final byte MAGIC_PONG = (byte)0x03; // 心跳 pong
    /**
     * The constant MAGIC_END.
     */
    public static final byte MAGIC_END = (byte)0x04; // 心跳 pong

    /**
     * The constant HEADER_LENGTH_MESSAGE.
     */
    public static final int HEADER_LENGTH_MESSAGE = 9; // 普通消息
    /**
     * The constant HEADER_LENGTH_PING.
     */
    public static final int HEADER_LENGTH_PING = 7; // 心跳 ping
    /**
     * The constant HEADER_LENGTH_PONG.
     */
    public static final int HEADER_LENGTH_PONG = 7; // 心跳 pong

    /**
     * The constant TYPE_ENTRY_FILE.
     */
    public static final int TYPE_ENTRY_FILE = PBBaseCommand.pbbasecommand.InstructionType.ENTRY_FILE_VALUE;
    /**
     * The constant TYPE_UPDATE.
     */
    public static final int TYPE_UPDATE = PBBaseCommand.pbbasecommand.InstructionType.UPDATE_VALUE;
    /**
     * The constant TYPE_RELOAD.
     */
    public static final int TYPE_RELOAD = PBBaseCommand.pbbasecommand.InstructionType.RELOAD_VALUE;
    /**
     * The constant TYPE_DEVICE.
     */
    public static final int TYPE_DEVICE = PBBaseCommand.pbbasecommand.InstructionType.DEVICE_VALUE;
    /**
     * The constant TYPE_CLOSE.
     */
    public static final int TYPE_CLOSE = PBBaseCommand.pbbasecommand.InstructionType.CLOSE_VALUE;
    /**
     * The constant TYPE_LOG.
     */
    public static final int TYPE_LOG = PBBaseCommand.pbbasecommand.InstructionType.LOG_VALUE;
    /**
     * The constant TYPE_ERROR.
     */
    public static final int TYPE_ERROR = PBBaseCommand.pbbasecommand.InstructionType.ERROR_VALUE;
    /**
     * The constant TYPE_MOVE.
     */
    public static final int TYPE_MOVE = PBBaseCommand.pbbasecommand.InstructionType.MOVE_VALUE;
    /**
     * The constant TYPE_REMOVE.
     */
    public static final int TYPE_REMOVE = PBBaseCommand.pbbasecommand.InstructionType.REMOVE_VALUE;
    /**
     * The constant TYPE_RENAME.
     */
    public static final int TYPE_RENAME = PBBaseCommand.pbbasecommand.InstructionType.RENAME_VALUE;
    /**
     * The constant TYPE_CREATE.
     */
    public static final int TYPE_CREATE = PBBaseCommand.pbbasecommand.InstructionType.CREATE_VALUE;
    /**
     * <code>COVERAGESUMMARY = 13;</code>
     */
    public static final int TYPE_CSUMMER = PBBaseCommand.pbbasecommand.InstructionType.COVERAGESUMMARY_VALUE;
    /**
     * <code>COVERAGEDETAIL = 14;</code>
     */
    public static final int TYPE_CDETAIL = PBBaseCommand.pbbasecommand.InstructionType.COVERAGEDETAIL_VALUE;
    /**
     * <code>COVREAGEVISUAL = 15;</code>
     */
    public static final int TYPE_CVISUAL = PBBaseCommand.pbbasecommand.InstructionType.COVREAGEVISUAL_VALUE;
    /**
     * The constant TYPE_PING.
     */
    public static final int TYPE_PING = PBBaseCommand.pbbasecommand.InstructionType.PING_VALUE;
    /**
     * The constant TYPE_PONG.
     */
    public static final int TYPE_PONG = PBBaseCommand.pbbasecommand.InstructionType.PONG_VALUE;

    public static final int TYPE_IPADDRESS = PBBaseCommand.pbbasecommand.InstructionType.IPADDRESS_VALUE;

    /**
     * The constant INDEX_MAGIC.
     */
    public static final int INDEX_MAGIC = 0;

    /**
     * The constant INDEX_MESSAGE_BODY_TYPE_START.
     */
//| MAGIC_MESSAGE (1 byte) | BodyType (4 byte) | BodyLength (4byte) | ...|
    public static final int INDEX_MESSAGE_BODY_TYPE_START = 1;
    /**
     * The constant INDEX_MESSAGE_BODY_TYPE_END.
     */
    public static final int INDEX_MESSAGE_BODY_TYPE_END = 4;
    /**
     * The constant INDEX_MESSAGE_BODY_LENGTH_START.
     */
    public static final int INDEX_MESSAGE_BODY_LENGTH_START = 5;
    /**
     * The constant INDEX_MESSAGE_BODY_LENGTH_END.
     */
    public static final int INDEX_MESSAGE_BODY_LENGTH_END = 8;

    /**
     * The constant INDEX_PING_IP_START.
     */
//| MAGIC_PING (1 byte) | ip (4 byte) | port (2byte) | ...|
    public static final int INDEX_PING_IP_START = 1;
    /**
     * The constant INDEX_PING_IP_END.
     */
    public static final int INDEX_PING_IP_END = 4;
    /**
     * The constant INDEX_PING_PORT_START.
     */
    public static final int INDEX_PING_PORT_START = 5;
    /**
     * The constant INDEX_PING_PORT_END.
     */
    public static final int INDEX_PING_PORT_END = 6;

    /**
     * The constant INDEX_PONG_IP_START.
     */
//| MAGIC_PONG (1 byte) | ip (4 byte) | port (2byte) | ...|
    public static final int INDEX_PONG_IP_START = 1;
    /**
     * The constant INDEX_PONG_IP_END.
     */
    public static final int INDEX_PONG_IP_END = 4;
    /**
     * The constant INDEX_PONG_PORT_START.
     */
    public static final int INDEX_PONG_PORT_START = 5;
    /**
     * The constant INDEX_PONG_PORT_END.
     */
    public static final int INDEX_PONG_PORT_END = 6;

}