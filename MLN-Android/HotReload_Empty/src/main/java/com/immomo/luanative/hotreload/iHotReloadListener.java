/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.hotreload;

import java.io.InputStream;

public interface iHotReloadListener {

    /**
     * 刷新.
     *
     * @param entryFilePath         入口文件的绝对路径
     * @param relativeEntryFilePath 入口文件的相对路径
     * @param params                需要传入的参数
     */
    public void onReload(String entryFilePath, String relativeEntryFilePath, String params);

    /**
     * 新建文件.
     *
     * @param filePath         文件的绝对路径
     * @param relativeFilePath 文件的相对路径
     */
    public void onFileCreate(String filePath, String relativeFilePath, InputStream is);

    /**
     * 文件内容更新.
     *
     * @param filePath         文件的绝对路径
     * @param relativeFilePath 文件的相对路径
     */
    public void onFileUpdate(String filePath, String relativeFilePath, InputStream is);

    /**
     * 重命名文件或文件夹.
     *
     * @param filePath            文件或文件夹的绝对路径
     * @param relativeFilePath    文件或文件夹的相对路径
     * @param newFilePath         新的文件或文件夹绝对路径
     * @param relativeNewFilePath 新的文件或文件夹相对路径
     */
    public void onFileRename(String filePath, String relativeFilePath, String newFilePath, String relativeNewFilePath);

    /**
     * 移动文件或文件夹.
     *
     * @param filePath            文件或文件夹的绝对路径
     * @param relativeFilePath    文件或文件夹的相对路径
     * @param newFilePath         新的文件或文件夹绝对路径
     * @param relativeNewFilePath 新的文件或文件夹相对路径
     */
    public void onFileMove(String filePath, String relativeFilePath,  String newFilePath,  String relativeNewFilePath);

    /**
     * 删除文件或文件夹.
     *
     * @param filePath         文件或文件夹的绝对路径
     * @param relativeFilePath 文件或文件夹的相对路径
     */
    public void onFileDelete(String filePath, String relativeFilePath);

    /**
     * 连接成功.
     *
     * @param type 连接类型（USB或Net)
     * @param ip   the ip
     * @param port the port
     */
    public void onConnected(int type, String ip, int port);

    /**
     * 连接断开.
     *
     * @param type  连接类型（USB或Net)
     * @param ip    the ip
     * @param port  the port
     * @param error 错误信息
     */
    public void disconnecte(int type, String ip, int port, String error);

    /**
     * 其他消息
     */
    public void onGencoveragereport();

    /**
     * 插件端将ip地址传入手机
     */
    public void onIpChanged(String ip);

}