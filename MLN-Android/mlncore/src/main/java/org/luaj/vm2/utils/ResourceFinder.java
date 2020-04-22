/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.utils;

/**
 * Created by Xiong.Fangyu on 2019/3/6
 * <p>
 * 资源寻找器，Lua脚本调用require时需要
 *
 * @see org.luaj.vm2.Globals#onRequire(String)
 */
public interface ResourceFinder {
    /**
     * 预处理模块名称
     * eg: return StringReplaceUtils.replaceAllChar(name, '.', '/') + ".lua";
     *
     * @param name 名称中一般不带后缀，且文件夹用.表示
     *             eg: path.moduleA
     * @return 名称
     */
    String preCompress(String name);

    /**
     * 寻找文件绝对路径
     * 第一优先
     *
     * @param name 名称
     * @return null or 绝对路径
     */
    String findPath(String name);

    /**
     * 获取Lua脚本或二进制数据
     *
     * @param name 名称
     * @return null or 数据
     */
    byte[] getContent(String name);

    /**
     * 当使用完{@link #getContent(String)}数据后，回调
     * @param name 名称
     */
    void afterContentUse(String name);

    /**
     * 若获取有错误，返回错误信息
     * @return 可为空
     */
    String getError();
}