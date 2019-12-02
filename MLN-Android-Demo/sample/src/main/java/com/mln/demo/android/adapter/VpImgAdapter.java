package com.mln.demo.android.adapter;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.mln.demo.android.entity.HomeRvEntity;

import java.util.ArrayList;
import java.util.List;

import androidx.viewpager.widget.PagerAdapter;

public class VpImgAdapter extends PagerAdapter {

    private List<String> images;
    private Intent intent;
    private Context context;

    public VpImgAdapter(Context context) {
        this.context = context;
        intent = new Intent();
        images = new ArrayList<>();
    }

    public void reSetData(HomeRvEntity item){
        images.clear();
        if (!TextUtils.isEmpty(item.getItempic())) {
            images.add(item.getItempic());
        }
        if (!TextUtils.isEmpty(item.getTaobao_image())) {
            images.add(item.getTaobao_image());
        }
    }

    @Override
    public int getCount() {
        return images.size();
    }

    @Override
    public boolean isViewFromObject(View arg0, Object arg1) {
        return arg0 == arg1;
    }

    @Override
    public Object instantiateItem(ViewGroup container, int position) {
        ImageView view = new ImageView(context);
        view.setScaleType(ImageView.ScaleType.CENTER_CROP);
        if (checkBound(images, position)) {
            Glide.with(context).load(images.get(position)).into(view);
        }
        container.addView(view, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        return view;
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
        if (object instanceof View) {
            ViewGroup parent = (ViewGroup) ((View) object).getParent();
            if (parent != null) {
                parent.removeView((View) object);
            }
        }
    }

    private boolean checkBound(List list, int index) {
        return index >= 0 && index < list.size();
    }
}
