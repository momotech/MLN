package com.immomo.mls.adapter.impl;

import androidx.annotation.NonNull;

import com.immomo.mls.Environment;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.adapter.MLSThreadAdapter;
import com.immomo.mls.global.LuaViewConfig;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.LogUtil;

import org.luaj.vm2.Globals;
import org.luaj.vm2.utils.IGlobalsUserdata;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class BeforeLuaAbortImpl implements Environment.BeforeAbortBlock {
    private static final String LogStart = "-----";
    private static final int LogStartLen = LogStart.length();
    private static volatile BeforeLuaAbortImpl instance;

    public static BeforeLuaAbortImpl getInstance() {
        if (instance == null) {
            synchronized (BeforeLuaAbortImpl.class) {
                if (instance == null) {
                    instance = new BeforeLuaAbortImpl();
                }
            }
        }
        return instance;
    }

    private BeforeLuaAbortImpl() {
    }

    @Override
    public void beforeAbort(Globals g, String msg) {
        final long now = System.currentTimeMillis();
        IGlobalsUserdata ud = g.getJavaUserdata();
        LuaViewManager m = ud instanceof LuaViewManager ? (LuaViewManager) ud : null;
        final StringBuilder sb = new StringBuilder(LogStart).append(now).append('\n');
        if (m == null) {
            sb.append("no lua view manager attach to ").append(g.toString());
        } else {
            sb.append("url: ").append(m.url)
                    .append(" script version: ").append(m.scriptVersion)
                    .append(" context info: ").append(m.context != null ? m.context.toString() : "no context info");
        }
        sb.append('\n')
                .append("abort message: ")
                .append(msg)
                .append('\n');
        File log = logFile();
        if (log == null) {
            LogUtil.e(sb.toString());
            return;
        }
        if (!log.exists()) {
            try {
                log.createNewFile();
            } catch (IOException e) {
                LogUtil.e(e, sb.toString());
            }
        }
        if (!log.exists()) {
            LogUtil.e(log + " create failed!");
            return;
        }
        long size = log.length();
        if (size == 0) {
            if (!FileUtil.save(log, sb.toString().getBytes())) {
                LogUtil.e(sb.toString());
            }
        } else {
            if (!FileUtil.append(log, (int) size, sb.toString().getBytes())) {
                LogUtil.e(sb.toString());
            }
        }
    }

    /**
     * 异步读日志，读完后，日志删除
     * callback在子线程中回调
     */
    public void asyncReadLog(final boolean delete, final AsyncReadLogCallback c) {
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new Runnable() {
            @Override
            public void run() {
                final List<Log> logs = readLog(delete);
                if (logs != null) {
                    c.onReadLog(logs);
                }
            }
        });
    }

    /**
     * 读完后，原日志文件会删除
     *
     * @return nullable
     */
    public List<Log> readLog(boolean delete) {
        File log = logFile();
        if (log == null || !log.isFile() || !log.canRead())
            return null;
        try {
            List<Log> ret = new ArrayList<>();
            String time = null;
            String msg = null;
            byte[] data = FileUtil.readBytes(log);
            int start = 0;
            int end = 0;
            int index = 0;
            int len = data.length;
            while (index < len) {
                if (data[index] == LogStart.charAt(0)
                        && isStart(data, index, len)) {
                    if (time != null) {
                        msg = new String(data, start, index - start);
                        try {
                            ret.add(new Log(Long.parseLong(time), msg));
                        } catch (Throwable ignore) {
                        }
                        time = null;
                    }
                    start = index + LogStartLen;
                    end = findNewLine(data, start, len);
                    if (end == -1) {
                        index++;
                        continue;
                    }
                    time = new String(data, start, end - start);
                    start = end + 1;
                    index = start;
                    continue;
                }
                index++;
            }
            if (time != null) {
                msg = new String(data, start, index - start);
                try {
                    ret.add(new Log(Long.parseLong(time), msg));
                } catch (Throwable ignore) {
                }
            }
            return ret;
        } catch (Exception e) {
            return null;
        } finally {
            if (delete)
                log.delete();
        }
    }

    private int findNewLine(byte[] data, int from, int end) {
        for (int i = from; i < end; i++) {
            if (data[i] == '\n')
                return i;
        }
        return -1;
    }

    private boolean isStart(byte[] data, int index, int end) {
        if (LogStartLen > end - index)
            return false;
        for (int i = 0; i < LogStartLen; i++) {
            if (LogStart.charAt(i) != data[index + 1])
                return false;
        }
        return true;
    }

    private File logFile() {
        final File dir = new File(LuaViewConfig.getLvConfig().getRootDir(), "LuaView");
        if (!dir.exists()) {
            dir.mkdirs();
        }
        if (!dir.exists())
            return null;
        return new File(dir, "abort_log");
    }

    public static class Log {
        public final long time;
        public final String message;

        public Log(long time, String message) {
            this.time = time;
            this.message = message;
        }

        @Override
        public String toString() {
            return "Log{" +
                    "time=" + time +
                    ", message='" + message + '\'' +
                    '}';
        }
    }

    public static interface AsyncReadLogCallback {
        void onReadLog(@NonNull List<Log> l);
    }
}