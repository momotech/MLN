/*
 * Created by LuaView.
 * Copyright (c) 2017, Alibaba Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

package com.mln.demo.activity;

import android.app.Activity;
import android.app.ListActivity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;

import com.immomo.mls.InitData;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.utils.MLSUtils;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class DemoActivity extends ListActivity {
    private static final String KEY = "__KEY";

    private static final String FOLDER_STANDARD_NAME = "test-standard";

    private String folderName;

    public static void startActivity(Activity a, String dir) {
        Intent i = new Intent(a, DemoActivity.class);
        i.putExtra(KEY, dir);
        a.startActivity(i);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent i = getIntent();
        folderName = i.getStringExtra(KEY);
        if (folderName == null) {
            folderName = FOLDER_STANDARD_NAME;
        }
        initContent();
    }

    private void initContent() {
        //for test
//        ScriptLoader.loadScript(new ParsedUrl(ScriptLoader.ASSETS_PREFIX + getFolderName() + "/cells/MomentNormalCell.lua"), true, null);
        final ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_expandable_list_item_1, getContentData());

        getListView().setAdapter(adapter);
        getListView().setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                final String fileName = getFileName(adapter.getItem(position - getListView().getHeaderViewsCount()));
                final Intent intent = new Intent(DemoActivity.this, LuaViewActivity.class);//DemoLuaViewActivity.class);
//                intent.putExtra(Constants.PARAM_URI, fileName);
                InitData initData = MLSBundleUtils.createInitData(fileName, false).forceNotUseX64().loadInMainThread();
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
        return "file://android_asset/" + folderName + "/" + n;
    }
}
