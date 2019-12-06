/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.demo.activity;

import android.app.Activity;
import android.app.ListActivity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;

import com.immomo.mls.Constants;
import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.activity.LuaViewActivity;
import com.immomo.mls.utils.MLSUtils;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Xiong.Fangyu on 2019-08-01
 */
public class AssetsChooserActivity extends ListActivity {
    private static final String KEY = "__KEY";

    private String folderName;

    public static void startActivity(Activity a, String dir) {
        Intent i = new Intent(a, AssetsChooserActivity.class);
        i.putExtra(KEY, dir);
        a.startActivity(i);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent i = getIntent();
        folderName = i.getStringExtra(KEY);
        if (folderName == null) {
            folderName = "";
        }
        initContent();
    }

    private void initContent() {
        final ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_expandable_list_item_1, getContentData());

        getListView().setAdapter(adapter);
        getListView().setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                final String fileName = getFileName(adapter.getItem(position - getListView().getHeaderViewsCount()));
                final Intent intent = new Intent(AssetsChooserActivity.this, LuaViewActivity.class);
                InitData initData = MLSBundleUtils.createInitData(fileName, false);
                initData.forceNotUseX64();
                intent.putExtras(MLSBundleUtils.createBundle(initData));
                startActivity(intent);
            }
        });
    }

    private List<String> getContentData() {
        String[] array = null;
        List<String> result = new ArrayList<String>();
        try {
            array = getResources().getAssets().list(folderName);

            if (array != null) {
                for (String name : array) {
                    if (MLSUtils.isLuaScript(name)) {
                        result.add(name);
//                        PreloadUtils.preload(getFileName(name));
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return result;
    }

    private String getFileName(String n) {
        return Constants.ASSETS_PREFIX + (TextUtils.isEmpty(folderName) ? n : folderName + File.separator + n);
    }
}