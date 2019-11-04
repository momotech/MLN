package com.mln.demo.activity;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

import com.immomo.mls.utils.MainThreadExecutor;
import com.mln.demo.R;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.DisposableIterator;

import java.util.Arrays;

/**
 * Created by Xiong.Fangyu on 2019/4/18
 */
public class LuaSDKTestActivity extends Activity {

    private TextView console;

    private Globals globals;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_lua_sdk_test);
        console = findViewById(R.id.console);

        globals = Globals.createLState(true);
        final LuaTable t = LuaTable.create(globals);
        t.set(1, 1);
        t.set(2, 2);
        t.set(3, 3);
        t.set(4, 4);
        log("table size" + t.size());
        log("dump1: " + Arrays.toString(globals.dump()));

        DisposableIterator<LuaTable.KV> disposableIterator = t.iterator();
        if (disposableIterator == null) {
            log("invalid table");
        } else {
            while (disposableIterator.hasNext()) {
                log("table next: " + disposableIterator.next().toString());
            }
            disposableIterator.dispose();
            log("dump2: " + Arrays.toString(globals.dump()));
        }

        log("table: " + t.newEntry().toString());

        new Thread(new DestroyTask(t)).start();
        MainThreadExecutor.post(new Task(globals));
        MainThreadExecutor.post(new Task(globals));
        MainThreadExecutor.post(new Task(globals));
        MainThreadExecutor.post(new Task(globals));
        MainThreadExecutor.post(new Task(globals));
        MainThreadExecutor.post(new Task(globals));
        MainThreadExecutor.post(new Task(globals));
        MainThreadExecutor.post(new Task(globals));
        MainThreadExecutor.post(new Task(globals));
        MainThreadExecutor.post(new Task(globals));
        MainThreadExecutor.post(new Task(globals));
        MainThreadExecutor.post(new Task(globals));
        MainThreadExecutor.post(new Task(globals));
        MainThreadExecutor.post(new Task(globals));
        log("dump3: " + Arrays.toString(globals.dump()));
//        Runtime.getRuntime().gc();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        globals.destroy();
    }

    private void log(String s) {
        console.append("\n");
        console.append(s);
    }

    private static class Task implements Runnable {
        Globals g;
        Task(Globals g) {
            this.g = g;
        }
        @Override
        public void run() {
            final LuaTable t2 = LuaTable.create(g);
            t2.set(1, 1);
            t2.set(2, 2);
            t2.set(3, 3);
            t2.set(4, 4);
            new Thread(new DestroyTask(t2)).start();
        }
    }

    private static class DestroyTask implements Runnable {
        LuaValue v;
        DestroyTask(LuaValue v) {
            this.v = v;
        }
        @Override
        public void run() {
            v.destroy();
        }
    }
}
