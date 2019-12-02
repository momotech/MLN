package com.mln.demo.android.presenter;

import android.content.Context;
import android.util.Log;


import com.mln.demo.android.adapter.IdeaLabelRvAdapter;
import com.mln.demo.android.entity.InspirHotEntity;
import com.mln.demo.android.interfaceview.BaseView;
import com.mln.demo.android.interfaceview.InspirView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

/**
 * Created by zhangxin
 * DateTime: 2019-11-08 14:55
 */
public class InspirPresenter extends BasePresenter<InspirHotEntity> {
    private Context context;
    private InspirView inspirView;

    public InspirPresenter(Context context, InspirView inspirView) {
        super();
        this.context = context;
        this.inspirView = inspirView;
    }

    @Override
    public BaseView<InspirHotEntity> getBaseView() {
        return this.inspirView;
    }

    protected List<InspirHotEntity> getData() {
        list.clear();
//        HttpHelper.reqHttp(HttpHelper.GET, "http://v2.api.haodanku.com/itemlist/apikey/fashion/cid/1/back/20?min_id=" + min_id + "&cid=" + cid, new HttpHelper.HttpCallback() {
//            @Override
//            public void successCallback(String res) {
        String res = null;
        InputStream is = null;
        try {
            is = context.getAssets().open("discoverry_detail.json");
            int lenght = is.available();
            byte[] buffer = new byte[lenght];
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
                            InspirHotEntity data = new InspirHotEntity();
                            data.setImgUrl(item.getString("album_500_500"));
                            data.setContent(item.getString("title"));
                            data.setIconUrl(item.getString("pic_small"));
                            data.setName(item.getString("author"));
                            data.setNum(item.getString("file_duration"));
                            list.add(data);
                            IdeaLabelRvAdapter.list0.add(data);
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
    protected List<InspirHotEntity> fetchData() {
        return list;
    }

}
