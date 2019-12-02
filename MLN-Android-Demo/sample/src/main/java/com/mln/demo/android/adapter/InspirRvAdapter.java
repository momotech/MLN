package com.mln.demo.android.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bumptech.glide.request.RequestOptions;
import com.mln.demo.R;
import com.mln.demo.android.entity.InspirHotEntity;
import com.mln.demo.android.util.Constant;
import com.mln.demo.mln.common.LoadWithTextView;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by zhangxin
 * DateTime: 2019-11-08 14:22
 */
public class InspirRvAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private final static int ViewTypeFooter = 0;
    private final static int ViewTypeNormal = 1;

    private final LoadWithTextView loadView;
    private Context context;
    private List<InspirHotEntity> list;

    public InspirRvAdapter(Context context) {
        this.context = context;
        list = new ArrayList<>();
        loadView = new LoadWithTextView(context);
    }

    public void updateList(List<InspirHotEntity> data) {
        list.clear();
        list.addAll(data);
        notifyDataSetChanged();
    }

    public void loadMore(List<InspirHotEntity> data) {
        list.addAll(list.size(), data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (viewType == ViewTypeFooter) {
            return new RecyclerViewFooterHolder(loadView);
        }
        View view = LayoutInflater.from(context).inflate(R.layout.inspir_list_item, parent,false);
        InspirRvHolder viewHolder = new InspirRvHolder(view);
        Glide.with(context).load(Constant.homeLoveImg).into(viewHolder.ivGood);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        if (holder instanceof RecyclerViewFooterHolder) {
            ((RecyclerViewFooterHolder) holder).loadView.setLoadText("加载更多");
            return;
        }
        if (holder instanceof InspirRvHolder) {
            InspirRvHolder inspirRvHolder = ((InspirRvHolder) holder);
            InspirHotEntity item = list.get(position);
            Glide.with(context).load(item.getImgUrl()).into(inspirRvHolder.ivHot);
            inspirRvHolder.tvContent.setText(item.getContent());
            Glide.with(context).load(item.getIconUrl()).apply(RequestOptions.bitmapTransform(new CircleCrop())).into(inspirRvHolder.ivIcon);
            inspirRvHolder.tvName.setText(item.getName());
            inspirRvHolder.tvNum.setText(item.getNum());
        }
    }

    @Override
    public int getItemCount() {
        return list.size()+1;
    }

    @Override
    public int getItemViewType(int position) {
        if (isFooterPosition(position)) {
            return ViewTypeFooter;
        }

        return ViewTypeNormal;
    }

    private boolean isFooterPosition(int position) {
        return position == list.size();
    }
    public class InspirRvHolder extends RecyclerView.ViewHolder {

        ImageView ivHot;
        TextView tvContent;
        ImageView ivIcon;
        TextView tvName;
        ImageView ivGood;
        TextView tvNum;

        public InspirRvHolder(@NonNull View itemView) {
            super(itemView);
            ivHot = itemView.findViewById(R.id.iv_hot);
            tvContent = itemView.findViewById(R.id.tv_content);
            ivIcon = itemView.findViewById(R.id.iv_icon);
            tvName = itemView.findViewById(R.id.tv_name);
            ivGood = itemView.findViewById(R.id.iv_good);
            tvNum = itemView.findViewById(R.id.tv_num);
        }
    }

    public static class RecyclerViewFooterHolder extends RecyclerView.ViewHolder {
        private LoadWithTextView loadView;

        public RecyclerViewFooterHolder(@NonNull LoadWithTextView itemView) {
            super(itemView);
            this.loadView= itemView;
        }
    }
}
