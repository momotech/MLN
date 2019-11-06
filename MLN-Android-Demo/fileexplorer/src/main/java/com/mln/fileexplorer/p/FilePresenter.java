package com.mln.fileexplorer.p;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.mln.fileexplorer.FileData;

import java.util.List;

/**
 * Created by Xiong.Fangyu on 2019-05-28
 */
public interface FilePresenter {

    void getChildren(@NonNull FileData dir, @NonNull Callback callback);

    interface Callback {
        /**
         * called in ui Thread
         */
        void onData(int errCode, @NonNull FileData dir, @Nullable List<FileData> data);
    }
}
