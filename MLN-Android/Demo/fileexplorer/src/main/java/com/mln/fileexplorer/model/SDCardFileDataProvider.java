package com.mln.fileexplorer.model;

import androidx.annotation.NonNull;

import com.mln.fileexplorer.FileData;
import com.mln.fileexplorer.IllegalParentException;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Xiong.Fangyu on 2019-05-28
 */
public class SDCardFileDataProvider implements FileDataProvider {
    @Override
    public @NonNull
    List<FileData> listChildren(FileData parent) throws IllegalParentException {
        if (!parent.isExists()) {
            throw new IllegalParentException(IllegalParentException.NOT_EXISTS);
        }
        if (!parent.isDirectory()) {
            throw new IllegalParentException(IllegalParentException.NOT_DIRECTORY);
        }
        File file = new File(parent.getPath(), parent.getName());
        File[] children = file.listFiles();
        if (children == null) {
            throw new IllegalParentException(IllegalParentException.NO_PERMISSION);
        }
        List<FileData> ret = new ArrayList<>(children.length + 1);
        for (File f : children) {
            ret.add(new FileData(f));
        }
        return ret;
    }
}
