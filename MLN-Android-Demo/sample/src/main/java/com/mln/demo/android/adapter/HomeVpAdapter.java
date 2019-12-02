package com.mln.demo.android.adapter;


import java.util.List;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;

/**
 * Created by xu.jingyu
 * DateTime: 2019-11-06 17:19
 */
public class HomeVpAdapter extends FragmentPagerAdapter {
    private FragmentManager fm;
    private List<Fragment> fragments;

    public HomeVpAdapter(FragmentManager fm, List<Fragment> fragments) {
        super(fm);
        this.fm = fm;
        this.fragments = fragments;
    }

    @Override
    public Fragment getItem(int position) {
        return fragments.get(position);
    }

    @Override
    public int getCount() {
        return fragments.size();
    }
}
