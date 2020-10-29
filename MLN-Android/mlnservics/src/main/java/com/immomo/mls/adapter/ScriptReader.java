/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.adapter;

import com.immomo.mls.utils.loader.ScriptInfo;

/**
 * Created by Xiong.Fangyu on 2018/11/1
 * 根据信息寻找或读取脚本
 */
public interface ScriptReader {
    /**
     * 根据信息开始寻找或读取脚本
     * 通过{@link ScriptInfo#callback}回调结果
     * @see ScriptInfo
     */
    void loadScriptImpl(final ScriptInfo info);

    /**
     * 脚本版本号，供debug使用
     */
    String getScriptVersion();

    /**
     * 任务tag
     */
    Object getTaskTag();

    /**
     * 页面销毁时调用
     */
    void onDestroy();
}