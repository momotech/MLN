package com.immomo.mls.weight.sweeplight;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.R;

import java.util.List;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

public class SweepLightAdapter extends RecyclerView.Adapter<SweepLightAdapter.SweepLightViewHolder> {
    private Context mContext;
    private List<Integer> data;

    public void setDarkMode(boolean darkMode) {
        isDarkMode = darkMode;
    }

    private boolean isDarkMode;

    public SweepLightAdapter(Context context, List<Integer> data) {
        this.mContext = context;
        this.data = data;
    }

    @NonNull
    @Override
    public SweepLightViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.item_commen_loading, viewGroup, false);
        return new SweepLightViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull SweepLightViewHolder holder, int i) {
        //此处为设计同学指定的透明度
        float alpha;
        switch (i) {
            case 0:
                alpha = 1f;
                break;
            case 1:
                alpha = isDarkMode ? 0.8f : 0.6f;
                break;
            case 2:
                alpha = isDarkMode ? 0.6f : 0.4f;
                break;
            case 3:
                alpha = isDarkMode ? 0.4f : 0.2f;
                break;
            default:
                alpha = isDarkMode ? 0.2f : 0.1f;
                break;
        }
        setBackGround(holder);

        Drawable mutate1 = holder.placeHolder1.getBackground().mutate();
        mutate1.setAlpha((int) (255 * alpha));
        Drawable mutate2 = holder.placeHolder2.getBackground().mutate();
        mutate2.setAlpha((int) (255 * alpha));
        Drawable mutate3 = holder.placeHolder3.getBackground().mutate();
        mutate3.setAlpha((int) (255 * alpha));
        Drawable mutate4 = holder.placeHolder4.getBackground().mutate();
        mutate4.setAlpha((int) (255 * alpha));
        Drawable mutate5 = holder.placeHolder5.getBackground().mutate();
        mutate5.setAlpha((int) (255 * alpha));
    }

    private void setBackGround(SweepLightViewHolder holder) {
        holder.placeHolder1.setBackgroundResource(isDarkMode ? R.drawable.circle_111111_bg : R.drawable.circle_f3f3f3_bg);
        holder.placeHolder2.setBackgroundResource(isDarkMode ? R.drawable.shape_111111_2dp_bg : R.drawable.shape_f3f3f3_2dp_bg);
        holder.placeHolder3.setBackgroundResource(isDarkMode ? R.drawable.shape_111111_2dp_bg : R.drawable.shape_f3f3f3_2dp_bg);
        holder.placeHolder4.setBackgroundResource(isDarkMode ? R.drawable.shape_111111_2dp_bg : R.drawable.shape_f3f3f3_2dp_bg);
        holder.placeHolder5.setBackgroundResource(isDarkMode ? R.drawable.shape_111111_2dp_bg : R.drawable.shape_f3f3f3_2dp_bg);
    }

    @Override
    public int getItemCount() {
        return data.size();
    }

    public static class SweepLightViewHolder extends RecyclerView.ViewHolder {
        protected View placeHolder1;
        protected View placeHolder2;
        protected View placeHolder3;
        protected View placeHolder4;
        protected View placeHolder5;

        public SweepLightViewHolder(@NonNull View itemView) {
            super(itemView);
            initView();
        }

        private void initView() {
            placeHolder1 = findViewById(R.id.placeHolder1);
            placeHolder2 = findViewById(R.id.placeHolder2);
            placeHolder3 = findViewById(R.id.placeHolder3);
            placeHolder4 = findViewById(R.id.placeHolder4);
            placeHolder5 = findViewById(R.id.placeHolder5);
        }

        protected <V extends View> V findViewById(int id) {
            return (V) itemView.findViewById(id);
        }
    }
}
