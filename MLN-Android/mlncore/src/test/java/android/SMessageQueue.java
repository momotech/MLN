/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package android;


import java.util.concurrent.BlockingDeque;
import java.util.concurrent.LinkedBlockingDeque;

/**
 * Created by Xiong.Fangyu on 2019-06-24
 */
public class SMessageQueue {

    private BlockingDeque<SMessage> messages = new LinkedBlockingDeque<>();

    private boolean quiting = false;

    SMessage next() {
        if (quiting) return null;
        try {
            SMessage next = messages.take();
            long offset = System.currentTimeMillis() - next.when;
            if (offset >= 0) return next;
            Thread.sleep(-offset);
            return next;
        } catch (InterruptedException e) {
            return null;
        }
    }

    void quit(boolean safe) {
        quiting = true;
        messages.clear();
    }

    boolean enqueueMessage(SMessage msg, long when) {
        if (msg.target == null) throw new IllegalArgumentException("Message must have a target.");

        if (quiting) return false;

        msg.when = when;
        return messages.offer(msg);
    }
}