/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.keyboard;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * For save the keyboard height.
 */
class KeyBoardSharedPreferences {

    private final static String FILE_NAME = "keyboard.mln";

    private final static String KEY_KEYBOARD_HEIGHT = "sp.key.mln.keyboard.height";

    private volatile static SharedPreferences SP;

    public static boolean save(final Context context, final int keyboardHeight) {
        return with(context).edit()
                .putInt(KEY_KEYBOARD_HEIGHT, keyboardHeight)
                .commit();
    }

    private static SharedPreferences with(final Context context) {
        if (SP == null) {
            synchronized (KeyBoardSharedPreferences.class) {
                if (SP == null) {
                    SP = context.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE);
                }
            }
        }

        return SP;
    }

    public static int get(final Context context, final int defaultHeight) {
        return with(context).getInt(KEY_KEYBOARD_HEIGHT, defaultHeight);
    }

}