package android;

/**
 * Created by Xiong.Fangyu on 2019-06-24
 */
public class SMessage {
    public int what;

    long when;

    SHandler target;

    Runnable callback;

    public static SMessage obtain() {
        return new SMessage();
    }
}
