package com.immomo.mls.processor;

import java.util.Map;

/**
 * Created by XiongFangyu on 2018/9/3.
 */
public class Options {
    public static final String SDK = "isSdk";
    public static final String SKIP_PACKAGE = "skipPackage";

    public boolean isSdk;
    public String[] skipPackage = {
            "com.immomo.mls"
    };

    public Options(Map<String, String> o) {
        if (o == null)
            return;
        isSdk = "true".equals(o.get(SDK));
        String sp = o.get(SKIP_PACKAGE);
        if (sp != null) {
            skipPackage = sp.split("\\|");
        }
    }
}
