package com.mln.demo.android.presenter;

import android.content.Context;
import android.util.Log;


import com.mln.demo.android.entity.HomeRvEntity;
import com.mln.demo.android.interfaceview.BaseView;
import com.mln.demo.android.interfaceview.IHomeView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

/**
 * Created by xu.jingyu
 * DateTime: 2019-11-07 14:55
 */
public class HomePresenter extends BasePresenter<HomeRvEntity> {
    private Context context;
    private IHomeView homeView;

    public HomePresenter(Context context, IHomeView homeView) {
        super();
        this.context = context;
        this.homeView = homeView;
    }


    @Override
    public BaseView<HomeRvEntity> getBaseView() {
        return homeView;
    }

    protected List<HomeRvEntity> getData() {
        list.clear();
//        HttpHelper.reqHttp(HttpHelper.GET, "http://v2.api.haodanku.com/itemlist/apikey/fashion/cid/1/back/20?min_id=" + min_id + "&cid=" + cid, new HttpHelper.HttpCallback() {
//            @Override
//            public void successCallback(String res) {
        String res = null;
        InputStream is = null;
        try {
            is = context.getAssets().open("fashion.json");
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
                    JSONArray array = obj.getJSONArray("data");
                    if (array != null && array.length() > 0) {
                        for (int i = 0; i < array.length(); i++) {
                            JSONObject item = array.getJSONObject(i);
                            HomeRvEntity data = new HomeRvEntity();
                            data.setCouponmoney(item.getString("couponmoney"));
                            data.setGeneral_index(item.getString("general_index"));
                            data.setItemdesc(item.getString("itemdesc"));
                            data.setItempic(item.getString("itempic"));
                            data.setItemsale(item.getString("itemsale"));
                            data.setItemshorttitle(item.getString("itemshorttitle"));
                            data.setSellernick(item.getString("sellernick"));
                            data.setTaobao_image(item.getString("taobao_image"));
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
    protected List<HomeRvEntity> fetchData() {
        return list;
    }

}
