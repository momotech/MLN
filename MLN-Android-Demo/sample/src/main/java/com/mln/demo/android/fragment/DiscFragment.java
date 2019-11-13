package com.mln.demo.android.fragment;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;


import com.mln.demo.R;
import com.mln.demo.android.adapter.DiscoverCellAdapter;
import com.mln.demo.android.entity.DiscoverCellEntity;
import com.mln.demo.android.interfaceview.DiscView;
import com.mln.demo.android.presenter.DiscPresenter;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

/**
 * Created by zhangxin
 * DateTime: 2019-11-07 14:49
 */
public class DiscFragment extends BaseFragment implements DiscView {
    private RecyclerView recyclerView;
    private DiscoverCellAdapter adapter;
    public static List<DiscoverCellEntity> mDiscoverCellEntity = new ArrayList<>();

    private Context context;
    private DiscPresenter presenter;

    private int mLastCompletelyVisibleItemPosition;
    private boolean footerShow = false;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return LayoutInflater.from(getContext()).inflate(R.layout.fragment_disc, container, false);
    }

    @Override
    int getConvertViewId() {
        return 0;
    }

    @Override
    void initData() {

    }

    @Override
    void initView() {

    }

    @Override
    void setListener() {

    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        context = getActivity();
        presenter = new DiscPresenter(context, (DiscView) this);

        initView(view);
    }

    //初始化View
    private void initView(View view) {
        recyclerView = (RecyclerView) view.findViewById(R.id.discovery_recycle);

        //瀑布流
        // GridLayoutManager layoutManager = new GridLayoutManager(getContext(),2);
        StaggeredGridLayoutManager layoutManager = new StaggeredGridLayoutManager(2, StaggeredGridLayoutManager.VERTICAL);
        /*layoutManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
            @Override
            public int getSpanSize(int i) {
                if (i == 0) {
                    return 2;
                } else {
                    return 1;
                }
            }
        });*/
        recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            int[] pos;

            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                if (footerShow) {
                    return;
                }
                mLastCompletelyVisibleItemPosition = lastCompletelyVisibleItemPosition(recyclerView);
            }

            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);

                if (canLoadMoreData(recyclerView, newState)) {
                    footerShow = true;
                    loadMoreData();
                }
            }

            private boolean canLoadMoreData(@NonNull RecyclerView recyclerView, int newState) {
                return didStopScroll(recyclerView, newState) && onBottom(recyclerView);
            }

            private boolean didStopScroll(@NonNull RecyclerView recyclerView, int newState) {
                return newState == RecyclerView.SCROLL_STATE_IDLE;
            }

            private boolean onBottom(@NonNull RecyclerView recyclerView) {
                return mLastCompletelyVisibleItemPosition >= ((StaggeredGridLayoutManager) recyclerView.getLayoutManager()).getItemCount() - 1;
            }

            private int lastCompletelyVisibleItemPosition(@NonNull RecyclerView recyclerView) {
                RecyclerView.LayoutManager lm = recyclerView.getLayoutManager();
                if (lm instanceof StaggeredGridLayoutManager) {
                    if (pos != null && ((StaggeredGridLayoutManager) lm).getSpanCount() != pos.length) {
                        pos = null;
                    }
                    pos = ((StaggeredGridLayoutManager) lm).findLastVisibleItemPositions(pos);
                    if (pos.length > 0) {
                        return pos[pos.length - 1];
                    }
                    return -1;
                }
                return -1;
            }
        });
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.setItemAnimator(null);
        adapter = new DiscoverCellAdapter(mDiscoverCellEntity);
        recyclerView.setAdapter(adapter);

        initDiscoverCell();
    }

    public void initDiscoverCell() {

//        sendRequestWithHttpURLConnection();
        presenter.syncGetData();

    }

    //加载更多
    private void loadMoreData() {
        presenter.syncFetchData();
    }

    @Override
    public void refreshUI(List<DiscoverCellEntity> list) {
       adapter.refreshUI(list);
    }

    @Override
    public void fetchUI(List<DiscoverCellEntity> list) {
        footerShow = false;
        adapter.notifyDataFetchUI(list);
    }
////
//
//    public static final int SHOW_RESPONSE = 0;
//    JSONArray data = null;
//    String title = null;
//
//    private Handler handler = new Handler() {
//        public void handleMessage(Message msg) {
//            switch (msg.what) {
//                case SHOW_RESPONSE:
//                    String response = (String) msg.obj;          // 在这里进行UI操作，将结果显示到界面上
////                    for (int i = 0; i< data.length(); i++) {
////                        DiscoverCellEntity entity = new DiscoverCellEntity(R.drawable.food, title, "更新了10篇内容");
////                        mDiscoverCellEntity.add(entity);
////                    }
//
//
//            }
//        }
//    };
//
//    private void sendRequestWithHttpURLConnection() {        // 开启线程来发起网络请求
//        new Thread(new Runnable() {
//        @Override
//        public void run() {
//            HttpURLConnection connection = null;
//            try {
//                URL url = new URL("http://v2.api.haodanku.com/activity_eleven_items/apikey/momozx/min_id/1/back/10");
//                connection = (HttpURLConnection) url.openConnection();
//                connection.setRequestMethod("GET");
//                connection.setConnectTimeout(8000);
//                connection.setReadTimeout(8000);
//                connection.setDoInput(true);
//                connection.setDoOutput(true);
//                InputStream in = connection.getInputStream();                    // 下面对获取到的输入流进行读取
//                BufferedReader reader = new BufferedReader( new InputStreamReader(in));
//                StringBuilder response = new StringBuilder();
//                String line;
//                while ((line = reader.readLine()) != null) {
//                    response.append(line);
//                }
//                Message message = new Message();
//                message.what = SHOW_RESPONSE;                    // 将服务器返回的结果存放到Message中
//                message.obj = response.toString();
//                handler.sendMessage(message);
//                parseJSON(response.toString());
//            } catch (Exception e) {
//                e.printStackTrace();
//            } finally {
//                if (connection != null) {
//                    connection.disconnect();
//                }
//            }
//        }
//    }).start();
//}
//
//
//    private void parseJSON(String jsonData) {
//        try {
//
//            JSONObject jsonObj = new JSONObject(jsonData);
//            // Getting JSON Array node
//            data = jsonObj.getJSONArray("data");
//            for (int i=0;i<data.length();i++){
//                JSONObject jsonObject=data.getJSONObject(i);
//                String url = jsonObject.getString("itempic");
//                title = jsonObject.getString("itemshorttitle");
////                DiscoverCellEntity entity = new DiscoverCellEntity(R.drawable.food, title, "更新了10篇内容");
////                mDiscoverCellEntity.add(entity);
//
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }


}
