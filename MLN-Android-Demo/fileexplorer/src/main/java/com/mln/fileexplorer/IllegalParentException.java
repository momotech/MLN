package com.mln.fileexplorer;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;

import static java.lang.annotation.RetentionPolicy.SOURCE;

/**
 * Created by Xiong.Fangyu on 2019-05-29
 */
public class IllegalParentException extends RuntimeException {

    public static final int NOT_EXISTS = -1;
    public static final int NOT_DIRECTORY = -2;
    public static final int NO_PERMISSION = -3;
    public static final int OTHER = -4;

    private static final String[] MSG = {
        "file not exists",
        "file not a directory",
        "no read permission",
        "unknown error"
    };

    @Retention(SOURCE)
    @IntDef({NOT_EXISTS, NOT_DIRECTORY, NO_PERMISSION, OTHER})
    public @interface CODE {}

    private final int code;

    public IllegalParentException(@CODE int code) {
        super(MSG[-code - 1]);
        this.code = code;
    }

    public IllegalParentException(int code, String msg) {
        super(msg);
        this.code = code;
    }

    public int getCode() {
        return code;
    }
}
