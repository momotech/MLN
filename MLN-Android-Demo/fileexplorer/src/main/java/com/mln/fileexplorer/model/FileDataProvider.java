package com.mln.fileexplorer.model;

import androidx.annotation.NonNull;

import com.mln.fileexplorer.FileData;
import com.mln.fileexplorer.IllegalParentException;

import java.util.List;

/**
 * Created by Xiong.Fangyu on 2019-05-28
 */
public interface FileDataProvider {

    @NonNull
    List<FileData> listChildren(FileData parent) throws IllegalParentException;
}
