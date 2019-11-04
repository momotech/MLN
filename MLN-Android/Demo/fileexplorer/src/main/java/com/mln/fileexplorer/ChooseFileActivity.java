package com.mln.fileexplorer;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.IntDef;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.mln.fileexplorer.model.AssetsFileDataProvider;
import com.mln.fileexplorer.model.FileDataProvider;
import com.mln.fileexplorer.model.SDCardFileDataProvider;
import com.mln.fileexplorer.p.DefaultFilePresenter;
import com.mln.fileexplorer.view.FileAdapter;

import java.io.File;
import java.lang.annotation.Retention;

import static java.lang.annotation.RetentionPolicy.SOURCE;

/**
 * Created by Xiong.Fangyu on 2019-05-29
 */
public class ChooseFileActivity extends AppCompatActivity {
    private static final String KEY_TYPE = "KEY_TYPE";
    private static final String KEY_ROOT = "KEY_ROOT";
    public static final String KEY_FILE = "KEY_FILE";

    public static final int TYPE_SDCARD = 0;
    public static final int TYPE_ASSETS = 1;

    @Retention(SOURCE)
    @IntDef({TYPE_SDCARD, TYPE_ASSETS})
    public @interface TYPE {}

    public static void startChooseFile(Activity context, int requestCode, @TYPE int type, String root) {
        Intent intent = new Intent(context, ChooseFileActivity.class);
        intent.putExtra(KEY_TYPE, type);
        intent.putExtra(KEY_ROOT, root);
        context.startActivityForResult(intent, requestCode);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        RecyclerView view = new RecyclerView(this);
        setContentView(view);

        view.setLayoutManager(new LinearLayoutManager(this));

        int type = getIntent().getIntExtra(KEY_TYPE, TYPE_SDCARD);
        String root = getIntent().getStringExtra(KEY_ROOT);
        final FileDataProvider provider;
        final FileData fileData;
        if (type == TYPE_SDCARD) {
            provider = new SDCardFileDataProvider();
            fileData = new FileData(new File(root));
        } else {
            provider = new AssetsFileDataProvider(this);
            int index = root.lastIndexOf(File.separatorChar);
            if (index > 0) {
                fileData = new FileData(root.substring(0, index), root.substring(index + 1));
            } else {
                fileData = new FileData("", root);
            }
        }
        FileAdapter adapter = new FileAdapter(new DefaultFilePresenter(provider));
        view.setAdapter(adapter);
        adapter.setRoot(fileData);
        adapter.setOnRootChangeListener(new FileAdapter.OnRootChangeListener() {
            @Override
            public void onChange(FileData root) {
                setTitle(root.getPath());
            }
        });
        adapter.setOnFileClickListener(new FileAdapter.OnFileClickListener() {
            @Override
            public boolean onFileClick(boolean isDir, FileData data) {
                if (isDir)
                    return false;
                Intent i = new Intent();
                i.putExtra(KEY_FILE, data.getPathName());
                setResult(RESULT_OK, i);
                finish();
                return true;
            }
        });
    }

    @Override
    public void onBackPressed() {
        setResult(RESULT_CANCELED);
        finish();
    }
}
