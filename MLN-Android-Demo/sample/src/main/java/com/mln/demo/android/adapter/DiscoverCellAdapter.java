package com.mln.demo.android.adapter;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Typeface;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.StyleSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.SearchView;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.mln.demo.R;
import com.mln.demo.android.activity.IdeaMassActivity;
import com.mln.demo.android.entity.DiscoverCellEntity;

import java.util.List;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

/**
 * Created by zhangxin
 * DateTime: 2019-11-07 14:49
 */

public class DiscoverCellAdapter extends RecyclerView.Adapter implements View.OnClickListener {


    private FragmentManager manager;
    public static final int TYPE_HEADER = 0; //带有Header的
    public static final int TYPE_NORMAL = 1; //不带有header的
    public static final int ViewTypeFooter = 2;

    private List<DiscoverCellEntity> mDiscoverCellEntityList;

    public DiscoverCellAdapter(List<DiscoverCellEntity> cellInfo) {
        mDiscoverCellEntityList = cellInfo;
        this.manager = manager;
    }

    public void refreshUI(List<DiscoverCellEntity> list) {
        mDiscoverCellEntityList.clear();
        mDiscoverCellEntityList.addAll(list);
        notifyDataSetChanged();
    }

    public void notifyDataFetchUI(List<DiscoverCellEntity> list) {
        int position=mDiscoverCellEntityList.size();
        mDiscoverCellEntityList.addAll(mDiscoverCellEntityList.size(), list);
        notifyItemRangeInserted(position,list.size());
        notifyItemRangeChanged(position,list.size());
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            //第一个item应该加载Header
            return TYPE_HEADER;
        } else if (isFooterPosition(position)) {
            return ViewTypeFooter;
        }
        return TYPE_NORMAL;
    }


    private boolean isFooterPosition(int position) {
        return position == mDiscoverCellEntityList.size() + getHeaderCount();
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {

        if (viewType == TYPE_HEADER) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.discovery_item_header, parent, false);
            StaggeredGridLayoutManager.LayoutParams lp = new StaggeredGridLayoutManager.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            lp.setFullSpan(true);
            itemView.setLayoutParams(lp);
            return new HeaderHolder(itemView);
        }
        if (viewType == ViewTypeFooter) {
            View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.footer_view_layout, parent, false);
            StaggeredGridLayoutManager.LayoutParams lp = new StaggeredGridLayoutManager.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            lp.setFullSpan(true);
            itemView.setLayoutParams(lp);
            return new RecyclerViewFooterHolder(itemView);
        }

        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.discovery_item, parent, false);

        view.setOnClickListener(this);
        return new ListHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        if (getItemViewType(position) == TYPE_NORMAL) {
            holder.itemView.setTag(position);
            //这里加载数据的时候要注意，是从position-1开始，因为position==0已经被header占用了
            DiscoverCellEntity discoverCellEntity = mDiscoverCellEntityList.get(position - 1);

            Glide.with(holder.itemView).load(discoverCellEntity.getImgUrl()).into(((ListHolder) holder).titleImage);
            ((ListHolder) holder).shopName.setText(discoverCellEntity.getName());
            ((ListHolder) holder).content.setText(discoverCellEntity.getContent());
        } else if (getItemViewType(position) == TYPE_HEADER) {

        }
    }

    @Override
    public void onClick(View view) {
        int position = (int) view.getTag();
        DiscoverCellEntity discoverCellEntity = mDiscoverCellEntityList.get(position-1);
        Intent intent = new Intent(view.getContext(), IdeaMassActivity.class);

        Activity a = (Activity) view.getContext();
        view.getContext().startActivity(intent);
        a.overridePendingTransition(R.anim.lv_slide_in_right, R.anim.lv_slide_out_left);

        // Toast.makeText(view.getContext(), "点击了cell" + discoverCellEntity.getName(), Toast.LENGTH_SHORT).show();

    }


    @Override
    public int getItemCount() {
        return mDiscoverCellEntityList.size() + getHeaderCount() + getFooterCount();
    }

    private int getHeaderCount() {
        return 1;
    }

    private int getFooterCount() {
        return 1;
    }

    //在这里面加载ListView中的每个item的布局
    private static class ListHolder extends RecyclerView.ViewHolder {

        private ImageView titleImage;
        private TextView shopName;
        private ImageView iconImage1;
        private TextView content;

        public ListHolder(View itemView) {
            super(itemView);

            titleImage = (ImageView) itemView.findViewById(R.id.iv_item_img);
            shopName = (TextView) itemView.findViewById(R.id.tv_item_name);
            iconImage1 = (ImageView) itemView.findViewById(R.id.iv_item_icon1);
            content = (TextView) itemView.findViewById(R.id.tv_item_content);
        }
    }

    public static class RecyclerViewFooterHolder extends RecyclerView.ViewHolder {
        private TextView mFooterTips;

        public RecyclerViewFooterHolder(@NonNull View itemView) {
            super(itemView);
            mFooterTips = (TextView) itemView.findViewById(R.id.footer_tips);
        }
    }

    /**
     * 推荐使用，用静态内部类。每一个viewType单独封装一个holder。
     */
    private static class HeaderHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        private TextView tvDiscover;
        private TextView tvMakeMoney;
        private SearchView svSearch;
        private ImageView useImage;
        private ImageView welfareImage;
        private TextView tvTask;
        private TextView tvLike;
        private TextView tvInspiration;
        private CheckBox btnSuggest;
        private CheckBox btnOutFit;
        private CheckBox btnMakeup;
        private CheckBox btnShop;
        private CheckBox btnTravel;

        private CheckBox currentSelectedBox;

        public HeaderHolder(View itemView) {
            super(itemView);
            initHeader(itemView);
        }

        private void initHeader(View itemView) {
            tvDiscover = itemView.findViewById(R.id.tv_discovery);
            tvMakeMoney = itemView.findViewById(R.id.tv_makeMoney);
            svSearch = itemView.findViewById(R.id.sv_search);
            useImage = itemView.findViewById(R.id.use_img);
            welfareImage = itemView.findViewById(R.id.welfare_img);
            tvTask = itemView.findViewById(R.id.tv_task);
            tvLike = itemView.findViewById(R.id.tv_like);
            tvInspiration = itemView.findViewById(R.id.tv_inspiration);
            btnSuggest = itemView.findViewById(R.id.sug_btn);
            btnOutFit = itemView.findViewById(R.id.outfit_btn);
            btnMakeup = itemView.findViewById(R.id.makeup_btn);
            btnShop = itemView.findViewById(R.id.shop_btn);
            btnTravel = itemView.findViewById(R.id.travel_btn);

            //首次选中
            currentSelectedBox = btnSuggest;
            currentSelectedBox.setChecked(true);

            View viewById = svSearch.findViewById(R.id.search_plate);

            String taskString = tvTask.getText().toString();
            SpannableString spanTask = new SpannableString(taskString);
            spanTask.setSpan(new StyleSpan(Typeface.BOLD), 0, 4, Spannable.SPAN_INCLUSIVE_INCLUSIVE);
            tvTask.setText(spanTask);

            String inspiration = tvInspiration.getText().toString();
            SpannableString spanInspiration = new SpannableString(inspiration);
            spanInspiration.setSpan(new AbsoluteSizeSpan(60), 0, 3, Spannable.SPAN_INCLUSIVE_INCLUSIVE);
            tvInspiration.setText(spanInspiration);

            tvMakeMoney.setOnClickListener(this);
            svSearch.setOnClickListener(this);
            welfareImage.setOnClickListener(this);
            tvLike.setOnClickListener(this);
            btnSuggest.setOnClickListener(this);
            btnOutFit.setOnClickListener(this);
            btnMakeup.setOnClickListener(this);
            btnShop.setOnClickListener(this);
            btnTravel.setOnClickListener(this);
        }

        @Override
        public void onClick(View view) {
            switch (view.getId()) {
                case R.id.tv_makeMoney:
                    Toast.makeText(view.getContext(), "去赚基金", Toast.LENGTH_SHORT).show();
                    break;
                case R.id.sv_search:
                    Toast.makeText(view.getContext(), "跳转到搜索页面", Toast.LENGTH_SHORT).show();
                    break;
                case R.id.welfare_img:
                    Toast.makeText(view.getContext(), "跳转到福利社页面", Toast.LENGTH_SHORT).show();
                    break;
                case R.id.tv_like:
                    Toast.makeText(view.getContext(), "去点赞", Toast.LENGTH_SHORT).show();
                    break;
                case R.id.sug_btn:
                    changeCheck(btnSuggest);
                    break;
                case R.id.outfit_btn:
                    changeCheck(btnOutFit);
                    break;
                case R.id.makeup_btn:
                    changeCheck(btnMakeup);
                    break;
                case R.id.shop_btn:
                    changeCheck(btnShop);
                    break;
                case R.id.travel_btn:
                    changeCheck(btnTravel);
                    break;
            }
        }

        //临时处理
        private void changeCheck(CheckBox checkBox) {
            if (currentSelectedBox != null) {
                currentSelectedBox.setChecked(false);
                currentSelectedBox = checkBox;
            }
            checkBox.setChecked(true);
        }

    }
}
