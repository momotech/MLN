/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.lifeCycle;


import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentManager;

import com.immomo.mmui.databinding.DataBinding;

import java.util.ArrayList;
import java.util.List;


/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-05-31 22:12
 */
public class FragmentLifecycle extends Fragment implements Lifecycle{
    private final List<LifecycleListener> lifecycleListeners = new ArrayList<>();

    private boolean isDestroyed;


    @Override
    public void addListener(LifecycleListener listener) {
        lifecycleListeners.add(listener);
        if (isDestroyed) {
            listener.onDestroy();
        }
    }

    @Override
    public void removeListener(LifecycleListener listener) {
        lifecycleListeners.remove(listener);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        isDestroyed = true;
        for (LifecycleListener lifecycleListener : lifecycleListeners) {
            lifecycleListener.onDestroy();
        }

    }

    public static FragmentLifecycle getLifeListenerFragment(Activity activity) {
        FragmentManager manager = activity.getFragmentManager();
        FragmentLifecycle fragment = (FragmentLifecycle) manager.findFragmentByTag(DataBinding.TAG);
        if (fragment == null) {
            fragment = new FragmentLifecycle();
            manager.beginTransaction().add(fragment, DataBinding.TAG).commitAllowingStateLoss();
        }
        return fragment;
    }

    public static FragmentLifecycle getLifeListenerFragment(Fragment parentFragment) {
        FragmentManager manager = parentFragment.getChildFragmentManager();
        FragmentLifecycle fragment = (FragmentLifecycle) manager.findFragmentByTag(DataBinding.TAG);
        if (fragment == null) {
            fragment = new FragmentLifecycle();
            manager.beginTransaction().add(fragment, DataBinding.TAG).commitAllowingStateLoss();
        }
        return fragment;
    }

}