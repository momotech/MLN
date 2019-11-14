package com.mln.demo.android.presenter;


import android.content.Context;
import android.util.Log;

import com.mln.demo.android.entity.DiscoverCellEntity;
import com.mln.demo.android.interfaceview.BaseView;
import com.mln.demo.android.interfaceview.DiscView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

/**
 * Created by zhangxin
 * DateTime: 2019-11-07 15:55
 */
public class DiscPresenter extends BasePresenter<DiscoverCellEntity> {
    private Context context;
    private DiscView discView;


    public DiscPresenter(Context context, DiscView discView) {
        super();
        this.context = context;
        this.discView = discView;
    }

    @Override
    public BaseView<DiscoverCellEntity> getBaseView() {
        return discView;
    }

    protected List<DiscoverCellEntity> getData() {
        list.clear();
//        HttpHelper.reqHttp(HttpHelper.GET, "http://v2.api.haodanku.com/itemlist/apikey/fashion/cid/1/back/20?min_id=" + min_id + "&cid=" + cid, new HttpHelper.HttpCallback() {
//            @Override
//            public void successCallback(String res) {
        String res = null;
        InputStream is = null;
        try {
            is = context.getAssets().open("discoverry.json");
            int length = is.available();
            byte[] buffer = new byte[length];
            is.read(buffer);
            res = new String(buffer, "utf8");
            Log.e("data", "res=" + res);
        } catch (IOException e) {
            e.printStackTrace();
        }
        if (res != null && !"".equals(res)) {
            try {
                JSONObject obj = new JSONObject(res);
                if (obj != null && !"".equals(obj)) {
//                            min_id = obj.getInt("min_id");
                    JSONArray array = obj.getJSONArray("result");
                    if (array != null && array.length() > 0) {
                        for (int i = 0; i < array.length(); i++) {
                            JSONObject item = array.getJSONObject(i);
                            DiscoverCellEntity data = new DiscoverCellEntity();
                            data.setImgUrl(item.getString("pic_huge"));
                            data.setName(item.getString("album_title"));
                            data.setContent("更新了" + item.getString("rank") + "篇内容");
                            list.add(data);
//                            Log.e("data", data.toString());
                        }
                        return list;
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
//            }
//
//            @Override
//            public void errorCallback() {
//
//            }
//        });
        return null;
    }

    @Override
    protected List<DiscoverCellEntity> fetchData() {
        return list;
    }

}
