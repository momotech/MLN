package com.mln.fileexplorer.view;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.mln.fileexplorer.FileData;
import com.mln.fileexplorer.IllegalParentException;
import com.mln.fileexplorer.R;
import com.mln.fileexplorer.p.FilePresenter;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Xiong.Fangyu on 2019-05-28
 */
public class FileAdapter extends RecyclerView.Adapter<FileViewHolder> implements View.OnClickListener, FilePresenter.Callback {

    private final List<FileData> data = new ArrayList<>();

    private final FilePresenter filePresenter;

    private Context context;

    private FileData root;
    private FileData currentRoot;

    private OnRootChangeListener onRootChangeListener;
    private OnFileClickListener onFileClickListener;

    public FileAdapter(FilePresenter filePresenter) {
        this.filePresenter = filePresenter;
    }

    protected int getLayoutID(int viewType) {
        return R.layout.fe_item_default_layout;
    }

    public void setRoot(FileData root) {
        this.root = root;
        currentRoot = root;
        filePresenter.getChildren(root, this);
    }

    public FileData getRoot() {
        return root;
    }

    public FileData getCurrentRoot() {
        return currentRoot;
    }

    public void setOnRootChangeListener(OnRootChangeListener onRootChangeListener) {
        this.onRootChangeListener = onRootChangeListener;
    }

    public void setOnFileClickListener(OnFileClickListener onFileClickListener) {
        this.onFileClickListener = onFileClickListener;
    }

    @NonNull
    @Override
    public FileViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (context == null)
            context = parent.getContext();
        return new FileViewHolder(LayoutInflater.from(context).inflate(getLayoutID(viewType), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull FileViewHolder holder, int position) {
        FileData fileData = data.get(position);
        holder.onBindData(fileData, position);
        View itemView = holder.itemView;
        itemView.setTag(fileData);
        itemView.setOnClickListener(this);
    }

    @Override
    public int getItemCount() {
        return data.size();
    }

    @Override
    public void onClick(View v) {
        FileData fileData = (FileData) v.getTag();
        if (fileData.isDirectory()) {
            onDirectoryClick(fileData);
        } else {
            onFileClick(fileData);
        }
    }

    protected void onDirectoryClick(FileData fileData) {
        if (onFileClickListener != null && onFileClickListener.onFileClick(true, fileData))
            return;
        filePresenter.getChildren(fileData, this);
    }

    protected void onFileClick(FileData fileData) {
        if (onFileClickListener != null && onFileClickListener.onFileClick(false, fileData))
            return;
        toast("file click");
    }

    @Override
    public void onData(int code, @NonNull FileData dir, @Nullable List<FileData> data) {
        if (data == null) {
            switch (code) {
                case IllegalParentException
                        .NOT_EXISTS:
                    toast("文件不存在");
                    break;
                case IllegalParentException.NOT_DIRECTORY:
                    toast("非文件夹");
                    break;
                case IllegalParentException.NO_PERMISSION:
                    toast("无权限");
                default:
                    toast("未知错误");
                    break;
            }
            return;
        }
        currentRoot = dir;
        this.data.clear();
        this.data.addAll(data);
        notifyDataSetChanged();
        if (onRootChangeListener != null)
            onRootChangeListener.onChange(currentRoot);
    }

    private void toast(String s) {
        if (context == null) return;
        Toast.makeText(context, s, Toast.LENGTH_LONG).show();
    }

    public interface OnRootChangeListener {
        void onChange(FileData root);
    }

    public interface OnFileClickListener {
        boolean onFileClick(boolean isDir, FileData data);
    }
}
