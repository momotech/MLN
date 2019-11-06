package com.mln.fileexplorer.p;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.mln.fileexplorer.FileData;
import com.mln.fileexplorer.IllegalParentException;
import com.mln.fileexplorer.model.FileDataProvider;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Xiong.Fangyu on 2019-05-28
 */
public class DefaultFilePresenter implements FilePresenter {

    private final FileDataProvider provider;

    private final Handler uiHandler;

    public DefaultFilePresenter(@NonNull FileDataProvider provider) {
        this.provider = provider;
        uiHandler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void getChildren(@NonNull final FileData dir, @NonNull Callback callback) {
        final WeakReference<Callback> ref = new WeakReference<>(callback);
        new Thread("FilePresenter") {
            @Override
            public void run() {
                if (ref.get() == null)
                    return;
                List<FileData> children = null;
                int code = 0;
                FileData parent = getParent(dir);
                try {
                    children = provider.listChildren(dir);
                    if (parent != null)
                    children.add(0, parent);
                } catch (IllegalParentException e) {
                    code = e.getCode();
                    switch (code) {
                        case IllegalParentException.NO_PERMISSION:
                            children = new ArrayList<>(1);
                            if (parent != null)
                                children.add(parent);
                            break;
                        default:
                            break;
                    }
                }
                uiHandler.post(new CallbackTask(dir, ref, children, code));
            }
        }.start();
    }

    private static FileData getParent(FileData src) {
        FileData data = src.getParent();
        if (data == null)
            return null;
        data.setParentDirectory(true);
        return data;
    }

    private static final class CallbackTask implements Runnable {
        final FileData dir;
        final WeakReference<Callback> ref;
        final List<FileData> data;
        final int code;

        private CallbackTask(FileData dir, WeakReference<Callback> ref, List<FileData> data, int code) {
            this.dir = dir;
            this.ref = ref;
            this.data = data;
            this.code = code;
        }

        @Override
        public void run() {
            if (ref.get() == null)
                return;
            ref.get().onData(code, dir, data);
        }
    }
}
