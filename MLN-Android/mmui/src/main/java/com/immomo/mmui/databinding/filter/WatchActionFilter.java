package com.immomo.mmui.databinding.filter;

import com.immomo.mmui.databinding.utils.Constants;
import com.immomo.mmui.databinding.utils.ObserverUtils;

/**
 * Description:通过key进行过滤
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/14 下午2:35
 */
public class WatchActionFilter implements IWatchKeyFilter{
    private String filterKey;

    public WatchActionFilter(String key) {
        this.filterKey = key;
    }

    @Override
    public boolean call(int argoWatchContext, String key, Object newer) {
        String[] tags = filterKey.split(Constants.SPOT_SPLIT);
        String observedTag;
        int finalNumIndex = ObserverUtils.getFinalNumFromTag(tags);
        if (finalNumIndex != -1) { //表示没有数字
            String beforeNumTag = ObserverUtils.getBeforeStr(tags, finalNumIndex);
            if (beforeNumTag.length() != filterKey.length()) {
                String afterNumTag = filterKey.substring(beforeNumTag.length() + 1);
                observedTag = new StringBuilder(tags[0]).append(Constants.SPOT).append(afterNumTag).toString();
            } else {
                observedTag = tags[0];
            }
        } else {
            observedTag = filterKey;
        }
        return key.equals(observedTag);
    }
}
