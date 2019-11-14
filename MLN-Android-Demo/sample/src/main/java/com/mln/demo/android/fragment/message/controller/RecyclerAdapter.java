package com.mln.demo.android.fragment.message.controller;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.mln.demo.R;
import com.mln.demo.android.fragment.message.model.MessageEntity;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

class RecyclerAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> implements View.OnClickListener {

    public interface OnItemClickListener {
        void onItemClick(View view, int position);
    }
    private OnItemClickListener mOnItemClickListener;
    private final int ViewTypeFooter = 0;
    private final int ViewTypeNormal = 1;
    private final int ViewTypeHeader = 2;

    private List<MessageEntity> mMessageList;
    private Context mContext;

    public RecyclerAdapter(Context context) {
        mContext = context;

        mMessageList = new ArrayList<>();
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.mOnItemClickListener = listener;
    }

    public static class RecyclerViewHeaderHolder extends RecyclerView.ViewHolder {
        private TextView mTitle;
        private TextView mRightInfo;
        private ImageView mAvatar;
        public RecyclerViewHeaderHolder(@NonNull View itemView) {
            super(itemView);
            mTitle = itemView.findViewById(R.id.titleInfo);
            mAvatar = itemView.findViewById(R.id.message_avatar);
            mRightInfo = itemView.findViewById(R.id.right_info);
        }
    }

    public static class RecyclerViewHolder extends RecyclerView.ViewHolder {
        private TextView mTitle;
        private Button mRightInfo;
        private ImageView mItemAvatar;

        public RecyclerViewHolder(@NonNull View itemView) {
            super(itemView);
            mTitle = itemView.findViewById(R.id.titleInfo);
            mItemAvatar = itemView.findViewById(R.id.item_avatar);
            mRightInfo = itemView.findViewById(R.id.right_info);
            mRightInfo.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mRightInfo.setSelected(!mRightInfo.isSelected());
                    mRightInfo.setText(attentionTip(mRightInfo.isSelected()));
                }

                private String attentionTip(Boolean isAttention) {
                    if (isAttention) {
                        return hasAttention();
                    } else {
                        return attention();
                    }
                }

                private String attention() {
                    return "+关注";
                }

                private String hasAttention() {
                    return "已关注";
                }
            });
        }
    }

    public static class RecyclerViewFooterHolder extends RecyclerView.ViewHolder {
        private TextView mFooterTips;
        public RecyclerViewFooterHolder(@NonNull View itemView) {
            super(itemView);
            mFooterTips = (TextView) itemView.findViewById(R.id.footer_tips);
        }
    }

    @Override
    public void onClick(View view) {
        if (mOnItemClickListener != null) {
            mOnItemClickListener.onItemClick(view, (int) view.getTag());
        }
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {

        if (viewType == ViewTypeHeader) {
            View itemView = (View) LayoutInflater.from(parent.getContext()).inflate(R.layout.message_item, parent, false);
            RecyclerViewHeaderHolder recyclerViewHeaderHolder = new RecyclerViewHeaderHolder(itemView);
            itemView.setOnClickListener(this);
            return recyclerViewHeaderHolder;
        }

        if (viewType == ViewTypeFooter) {
            View itemView = (View) LayoutInflater.from(parent.getContext()).inflate(R.layout.footer_view_layout, parent, false);
            RecyclerViewFooterHolder recyclerViewFooterHolder = new RecyclerViewFooterHolder(itemView);
            return recyclerViewFooterHolder;
        }

        View itemView = (View) LayoutInflater.from(parent.getContext()).inflate(R.layout.item_layout, parent, false);
        itemView.setOnClickListener(this);
        RecyclerViewHolder recyclerViewHolder = new RecyclerViewHolder(itemView);
        return  recyclerViewHolder;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        if (holder instanceof RecyclerViewHeaderHolder) {
            ((RecyclerViewHeaderHolder)holder).mTitle.setText(mMessageList.get(position).getFemalename());

            ((RecyclerViewHeaderHolder)holder).mRightInfo.setText(getRightInfo(position));
            setAvatarWithPosition((RecyclerViewHeaderHolder) holder, position);
            holder.itemView.setTag(position);
            return;
        }

        if (holder instanceof RecyclerViewFooterHolder) {
            ((RecyclerViewFooterHolder) holder).mFooterTips.setText(R.string.footer_tips);
            return;
        }

        ((RecyclerViewHolder)holder).mTitle.setText(mMessageList.get(position).getFemalename());
        Glide.with(mContext)
                .load(mMessageList.get(position).getIcon())
                .into(((RecyclerViewHolder)holder).mItemAvatar);

        holder.itemView.setTag(position);
    }

    private void setAvatarWithPosition(@NonNull RecyclerViewHeaderHolder holder, int position) {
        if (position == 0) {
            holder.mAvatar.setImageResource(R.drawable.server);
        } else if (position == 1) {
            holder.mAvatar.setImageResource(R.drawable.biling);
        }
    }

    private String getRightInfo(int position) {
        return ">";
    }

    @Override
    public int getItemViewType(int position) {
        if (isFooterPosition(position)) {
            return ViewTypeFooter;
        }

        if (position == 0 || position ==1) {
            return ViewTypeHeader;
        }

        return ViewTypeNormal;
    }

    private boolean isFooterPosition(int position) {
        return position == mMessageList.size();
    }

    @Override
    public int getItemCount() {
        return mMessageList.size() + showFooter();
    }

    private int showFooter() {
        return 1;
    }

    public void notifyMessageDataSetChangedWith(List<MessageEntity> list) {
        makeSureSafeForMessageList();
        mMessageList.addAll(list);
        notifyDataSetChanged();
    }

    private void makeSureSafeForMessageList() {
        if (isNullMessageList()) {
            mMessageList = new ArrayList<>();
        }

        if (!isEmptyMessageContainer()) {
            mMessageList.clear();
        }
    }

    private boolean isNullMessageList() {
        return mMessageList == null;
    }

    private boolean isEmptyMessageContainer() {
        if (mMessageList.size() == 0) {
            return true;
        }
        return false;
    }

}
