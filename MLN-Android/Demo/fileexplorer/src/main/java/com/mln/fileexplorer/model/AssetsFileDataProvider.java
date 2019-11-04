package com.mln.fileexplorer.model;

import android.content.Context;

import com.mln.fileexplorer.FileData;
import com.mln.fileexplorer.IllegalParentException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;

/**
 * Created by Xiong.Fangyu on 2019-05-29
 */
public class AssetsFileDataProvider implements FileDataProvider {
    private final Context context;

    public AssetsFileDataProvider(@NonNull Context context) {
        this.context = context;
    }

    @NonNull
    @Override
    public List<FileData> listChildren(FileData parent) throws IllegalParentException {
        try {
            String pp = parent.getPathName();
            String[] children = context.getAssets().list(pp);
            int len = children != null ? children.length : 0;
            List<FileData> ret = new ArrayList<>(len + 1);
            for (int i = 0; i < len; i ++) {
                FileData fd = new FileData(pp, children[i]);
                fd.setType(FileData.TYPE_ASSETS);
                fd.setExist(true);
                fd.setDirectory(checkIsDirectory(fd));
                ret.add(fd);
            }
            return ret;
        } catch (IOException e) {
            throw new IllegalParentException(IllegalParentException.OTHER);
        }
    }

    private boolean checkIsDirectory(FileData data) {
        try {
            String pn = data.getPathName();
            context.getAssets().open(pn).close();
            return false;
        } catch (IOException e) {
            return true;
        }
    }
}
