package com.immomo.mls.bean;

public class LightLuaBean {
    public LightLuaBean(String entryUrl, String downloadUrl,boolean forceLoadAsset) {
        this.entryUrl = entryUrl;
        this.downloadUrl = downloadUrl;
        this.forceLoadAsset = forceLoadAsset;
    }

    /**
     * 入口文件地址
     */
    private String entryUrl;
    /**
     * 版本号
     */
    private String version;
    /**
     * 下载地址
     */
    private String downloadUrl;
    /**
     * 是否强制加载本地资源文件
     */
    private boolean forceLoadAsset;

    public String getEntryUrl() {
        return entryUrl;
    }

    public void setEntryUrl(String entryUrl) {
        this.entryUrl = entryUrl;
    }

    public String getDownloadUrl() {
        return downloadUrl;
    }

    public void setDownloadUrl(String downloadUrl) {
        this.downloadUrl = downloadUrl;
    }

    public boolean isForceLoadAsset() {
        return forceLoadAsset;
    }

    public void setForceLoadAsset(boolean forceLoadAsset) {
        this.forceLoadAsset = forceLoadAsset;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    @Override
    public String toString() {
        return "LightLuaBean{" +
                "entryUrl='" + entryUrl + '\'' +
                ", version='" + version + '\'' +
                ", downloadUrl='" + downloadUrl + '\'' +
                ", forceLoadAsset=" + forceLoadAsset +
                '}';
    }
}
