/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package com.mln.demo.weex.utils;

import android.os.AsyncTask;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public class DefaultThreadAdapter implements MLSThreadAdapter {
    private final Map<Object, List<TASK>> taskMap = new HashMap<>();

    @Override
    public void execute(Priority p, Runnable action) {
        Thread t = new Thread(action);
        t.setPriority(p == Priority.HIGH ? Thread.MAX_PRIORITY : Thread.MIN_PRIORITY);
        t.start();
    }

    @Override
    public void executeTaskByTag(Object tag, final Runnable task) {
        new TASK(tag, task).executeInPool();
    }

    @Override
    public void cancelTask(Object tag, Runnable task) {
        List<TASK> t = taskMap.get(tag);
        if (t == null)
            return;
        int i = 0;
        int l = t.size();
        for (i = 0; i < l;i ++) {
            TASK task1 = t.get(i);
            if (task1.sameTask(task)) {
                task1.cancel(true);
                break;
            }
        }
        t.remove(i);
        if (t.isEmpty())
            taskMap.remove(tag);
    }

    @Override
    public void cancelTaskByTag(Object tag) {
        List<TASK> t = taskMap.remove(tag);
        if (t == null)
            return;
        for (TASK tt : t) {
            tt.cancel(true);
        }
        t.clear();
    }

    private final class TASK extends AsyncTask<Void, Void, Void> {
        private Object tag;
        private List<TASK> list;
        Runnable innerTask;
        TASK(Object tag, Runnable innerTask) {
            this.innerTask = innerTask;
            this.tag = tag;
            list = taskMap.get(tag);
            if (list == null) {
                list = new ArrayList<>();
                taskMap.put(tag, list);
            }
            list.add(this);
        }

        @Override
        public boolean equals(Object that) {
            return super.equals(that)
                    || ((that instanceof TASK) && sameTask(((TASK) that).innerTask))
                    || ((that instanceof Runnable) && sameTask((Runnable) that));
        }

        public boolean sameTask(Runnable other) {
            return other.equals(innerTask);
        }

        @Override
        protected Void doInBackground(Void... voids) {
            innerTask.run();
            list.remove(this);
            if (list.isEmpty()) {
                taskMap.remove(tag);
            }
            return null;
        }

        public void executeInPool(Void... values) {
            super.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, values);
        }
    }
}
