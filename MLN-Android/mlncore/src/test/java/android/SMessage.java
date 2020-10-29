/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package android;

/**
 * Created by Xiong.Fangyu on 2019-06-24
 */
public class SMessage {
    public int what;

    long when;

    SHandler target;

    Runnable callback;

    public static SMessage obtain() {
        return new SMessage();
    }
}