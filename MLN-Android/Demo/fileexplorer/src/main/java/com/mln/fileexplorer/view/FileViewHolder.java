package com.mln.fileexplorer.view;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.mln.fileexplorer.FileData;
import com.mln.fileexplorer.R;

/**
 * Created by Xiong.Fangyu on 2019-05-28
 */
public class FileViewHolder extends RecyclerView.ViewHolder {
    protected ImageView icon;
    protected TextView title;
    protected TextView desc;

    public FileViewHolder(@NonNull View itemView) {
        super(itemView);
        initView();
    }

    protected void initView() {
        icon = findViewById(R.id.ef_item_icon);
        title = findViewById(R.id.ef_item_title);
        desc = findViewById(R.id.ef_item_desc);
    }

    public void onBindData(FileData data, int position) {
        if (data.isParentDirectory()) {
            icon.setImageResource(R.drawable.ef_icon_directory);
            title.setText("..");
            desc.setText("上层文件夹");
        } else {
            if (data.isDirectory())
                icon.setImageResource(R.drawable.ef_icon_directory);
            else
                icon.setImageResource(R.drawable.ef_icon_file);
            title.setText(data.getName());
            desc.setText(data.getDesc());
        }
    }

    protected <V extends View> V findViewById(int id) {
        return (V) itemView.findViewById(id);
    }
}
