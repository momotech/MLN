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

import java.util.List;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by zhangxin
 * DateTime: 2019-11-08 14:22
 */
public class InspirRvAdapter extends RecyclerView.Adapter<InspirRvAdapter.InspirRvHolder> {

    private Context context;
    private FragmentManager manager;
    private List<InspirHotEntity> list;
    private List<View> vpImgs;

    public InspirRvAdapter(Context context, List<InspirHotEntity> list, FragmentManager manager) {
        this.context = context;
        this.list = list;
        this.manager = manager;
    }

    @NonNull
    @Override
    public InspirRvHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.inspir_list_item, null);
        InspirRvHolder viewHolder = new InspirRvHolder(view);
        Glide.with(context).load(Constant.homeLoveImg).into(viewHolder.ivGood);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(@NonNull InspirRvHolder holder, int position) {
        InspirHotEntity item = list.get(position);
        Glide.with(context).load(item.getImgUrl()).into(holder.ivHot);
        holder.tvContent.setText(item.getContent());
        Glide.with(context).load(item.getIconUrl()).apply(RequestOptions.bitmapTransform(new CircleCrop())).into(holder.ivIcon);
        holder.tvName.setText(item.getName());
        holder.tvNum.setText(item.getNum());

    }

    @Override
    public int getItemCount() {
        return list.size();
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

}
