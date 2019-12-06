package com.mln.demo.android.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.immomo.mls.utils.MainThreadExecutor;
import com.mln.demo.R;
import com.mln.demo.android.entity.HomeRvEntity;
import com.mln.demo.android.util.Constant;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager.widget.ViewPager;

/**
 * Created by xu.jingyu
 * DateTime: 2019-11-06 20:22
 */
public class HomeRvAdapter extends RecyclerView.Adapter {
    private final static int ViewTypeFooter = 0;
    private final static int ViewTypeNormal = 1;

    private Context context;
    private FragmentManager manager;
    private List<HomeRvEntity> list;
    private List<View> vpImgs;

    private HashMap<HomeViewHolder, Integer> lazyTasks;
    private boolean canCallFillCell = true;


    public HomeRvAdapter(Context context, List<HomeRvEntity> list, FragmentManager manager) {
        this.context = context;
        this.list = list;
        this.manager = manager;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (viewType == ViewTypeFooter) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.footer_view_layout, parent, false);
            RecyclerViewFooterHolder recyclerViewFooterHolder = new RecyclerViewFooterHolder(itemView);
            return recyclerViewFooterHolder;
        }
        View view = LayoutInflater.from(context).inflate(R.layout.home_list_item, null);
        HomeViewHolder viewHolder = new HomeViewHolder(view);
        Glide.with(context).load(Constant.homeShareImg).into(viewHolder.ivShare);
        Glide.with(context).load(Constant.homeLoveImg).into(viewHolder.ivLove);
        Glide.with(context).load(Constant.homeCommentImg).into(viewHolder.ivComment);
        Glide.with(context).load(Constant.homeCollectImg).into(viewHolder.ivCollect);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {

        if (holder instanceof HomeViewHolder) {
            HomeViewHolder homeViewHolder = (HomeViewHolder) holder;
            HomeRvEntity item = list.get(position);
            Glide.with(context).load(item.getItempic()).apply(RequestOptions.circleCropTransform()).into(homeViewHolder.ivHeader);
            homeViewHolder.tvName.setText(item.getSellernick());
            homeViewHolder.tvDesc.setText(item.getItemdesc());
            Glide.with(context).load(item.getItempic()).into(homeViewHolder.ivContentImg);
            homeViewHolder.tvContentFrom.setText(item.getItemshorttitle());
            homeViewHolder.tvContentDesc.setText(item.getItemdesc());
            homeViewHolder.tvContentNum.setText(String.format("%s篇内容>  ", item.getCouponmoney()));

            if (canCallFillCell) {
                homeViewHolder.bindData(item);   // 更新图片数据
            } else {
                if (lazyTasks == null) {
                    lazyTasks = new HashMap<>();
                }

                lazyTasks.put(homeViewHolder, position);
            }
        }
    }


    public void setRecyclerState(int state) {
        canCallFillCell = state != RecyclerView.SCROLL_STATE_SETTLING;
        if (canCallFillCell && lazyTasks != null) {
            MainThreadExecutor.post(lazyCallFillCellTask);
        }
    }

    private Runnable lazyCallFillCellTask = new Runnable() {
        @Override
        public void run() {
            if (lazyTasks == null || lazyTasks.isEmpty())
                return;

            for (Map.Entry<HomeViewHolder, Integer> entry : lazyTasks.entrySet()) {
                entry.getKey().bindData(list.get(entry.getValue()));
            }
            lazyTasks.clear();
        }
    };

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

    @Override
    public int getItemCount() {
        return list.size() + 1;
    }

    static class HomeViewHolder extends RecyclerView.ViewHolder {

        ImageView ivHeader;
        TextView tvName;
        TextView tvAttention;
        ViewPager vpImages;
        TextView tvDesc;
        ImageView ivContentImg;
        TextView tvContentNum;
        TextView tvContentFrom;
        TextView tvContentDesc;
        ImageView ivShare;
        ImageView ivCollect;
        ImageView ivComment;
        ImageView ivLove;

        VpImgAdapter vpImgAdapter;

        public HomeViewHolder(@NonNull View itemView) {
            super(itemView);
            ivHeader = itemView.findViewById(R.id.iv_header);
            tvName = itemView.findViewById(R.id.tv_name);
            tvAttention = itemView.findViewById(R.id.tv_attention);
            vpImages = itemView.findViewById(R.id.vp_images);
            tvDesc = itemView.findViewById(R.id.tv_desc);
            ivContentImg = itemView.findViewById(R.id.iv_content_img);
            tvContentNum = itemView.findViewById(R.id.tv_content_num);
            tvContentFrom = itemView.findViewById(R.id.tv_content_from);
            tvContentDesc = itemView.findViewById(R.id.tv_content_desc);
            ivShare = itemView.findViewById(R.id.iv_share);
            ivCollect = itemView.findViewById(R.id.iv_collect);
            ivComment = itemView.findViewById(R.id.iv_comment);
            ivLove = itemView.findViewById(R.id.iv_love);

            vpImgAdapter = new VpImgAdapter(itemView.getContext());
            vpImages.setAdapter(vpImgAdapter);
        }

        void bindData(HomeRvEntity item) {
            vpImgAdapter.reSetData(item);
            vpImgAdapter.notifyDataSetChanged();
        }
    }


    public static class RecyclerViewFooterHolder extends RecyclerView.ViewHolder {
        private TextView mFooterTips;

        public RecyclerViewFooterHolder(@NonNull View itemView) {
            super(itemView);
            mFooterTips = itemView.findViewById(R.id.footer_tips);
        }
    }
}
