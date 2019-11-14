package com.mln.demo.android.fragment.message.controller;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.mln.demo.R;
import com.mln.demo.android.fragment.message.model.MessageEntity;
import com.mln.demo.android.fragment.message.model.MessageManager;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

public class MessageFragment extends Fragment implements SwipeRefreshLayout.OnRefreshListener {
    private View mView;
    private RecyclerView mRecyclerView;
    private RecyclerView.LayoutManager mLayoutManager;
    private SwipeRefreshLayout mRefreshLayout;
    private RecyclerAdapter mAdapter;
    private int mLastCompletelyVisibleItemPosition;
    private Handler mMessageHandler;

    private MessageManager mMessageManager;

    private MessageManager mAsyncMessageManager;


    private List<MessageEntity> mMessageList;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        mView = inflater.inflate(R.layout.fragment_message, container, false);
        setUpMessage();
        setUpRecyclerView();
        setUpSwipeRefreshLayout();

        return mView;
    }

    private void setUpMessage() {
        setUpMessageHandler();
        mMessageList = new ArrayList<MessageEntity>();
        mMessageManager = new MessageManager(getActivity());
        mAsyncMessageManager = new MessageManager(getActivity(), mMessageHandler);
    }

    private void setUpMessageHandler() {
        mMessageHandler = new Handler() {
            @Override
            public void handleMessage(Message msg) {

                switch (msg.what) {
                    case 1:
                        resetData(msg);
                        stopRefresh();
                        break;
                    case 2:
                        getMoreData(msg);
                        break;
                    default:
                        return;
                }

            }
        };
    }

    private void getMoreData(Message msg) {
        addMessagesToListWith((List<MessageEntity>) msg.obj);
        mAdapter.notifyMessageDataSetChangedWith(mMessageList);
    }

    private void resetData(Message msg) {
        mMessageList.clear();
        addMessagesToListWith((List<MessageEntity>) msg.obj);
        mAdapter.notifyMessageDataSetChangedWith(mMessageList);
    }

    private void setUpSwipeRefreshLayout() {
        mRefreshLayout = (SwipeRefreshLayout) mView.findViewById(R.id.refresh);
        mRefreshLayout.setProgressViewOffset(true, 20, 100);
        mRefreshLayout.setSize(SwipeRefreshLayout.DEFAULT);
        mRefreshLayout.setColorSchemeResources(R.color.colorPrimary, R.color.colorPrimaryDark, R.color.colorAccent);
        mRefreshLayout.setEnabled(true);
        mRefreshLayout.setOnRefreshListener(this);
    }

    @Override
    public void onRefresh() {
        resetDataAsync();
    }

    private void stopRefresh() {
        if (mRefreshLayout.isRefreshing()) {
            mRefreshLayout.setRefreshing(false);
        }
    }

    private void setUpRecyclerView() {
        setRecyclerView();
        setLayoutManager();
        setAdapter();
    }

    private void setRecyclerView() {
        mRecyclerView = (RecyclerView) mView.findViewById(R.id.recyclerview);
        mRecyclerView.setHasFixedSize(true);
        loadMoreDataAsync();
        mRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {

            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy){
                mLastCompletelyVisibleItemPosition = lastCompletelyVisibleItemPosition(recyclerView);
            }

            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);

                if (canLoadMoreData(recyclerView, newState)) {
                    loadMoreDataAsync();
                }
            }

            private boolean canLoadMoreData(@NonNull RecyclerView recyclerView, int newState) {
                return didStopScroll(recyclerView, newState) && onBottom(recyclerView);
            }

            private boolean didStopScroll(@NonNull RecyclerView recyclerView, int newState) {
                return newState == RecyclerView.SCROLL_STATE_IDLE;
            }

            private boolean onBottom(@NonNull RecyclerView recyclerView) {
                return mLastCompletelyVisibleItemPosition >= ((LinearLayoutManager) recyclerView.getLayoutManager()).getItemCount() - 1;
            }

            private int lastCompletelyVisibleItemPosition(@NonNull RecyclerView recyclerView) {
                RecyclerView.LayoutManager lm = recyclerView.getLayoutManager();
                if (lm instanceof LinearLayoutManager) {
                    return ((LinearLayoutManager) lm).findLastVisibleItemPosition();
                }
                return -1;
            }
        });
    }

    private void setAdapter() {
        mAdapter = new RecyclerAdapter(getActivity());
        mAdapter.setOnItemClickListener(new RecyclerAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                startActivityWith(position);
                showAlert(position);
            }

            private void startActivityWith(int position) {
                if (position == 0) {
                    startActivity(new Intent(getContext(), MessageDetailActivity.class));
                } else if (position == 1) {
                    startActivity(new Intent(getContext(), MessageDetailNotificationActivity.class));
                }
            }

            private void showAlert(int position) {
                Toast.makeText(mView.getContext(), mMessageList.get(position).getFemalename(), Toast.LENGTH_SHORT).show();
            }
        });
        mRecyclerView.setAdapter(mAdapter);
    }

    private void setLayoutManager() {
        mLayoutManager = new LinearLayoutManager(mView.getContext());
        mRecyclerView.setLayoutManager(mLayoutManager);
    }

    private void resetDataAsync() {
        mMessageList.clear();
        mAsyncMessageManager.fetchMessageDataAsync();
    }

    private void loadMoreDataAsync() {
        mAsyncMessageManager.fetchMoreMessageDataAsync();
    }

    private void addMessagesToListWith(List<MessageEntity> list) {
        if (mMessageList == null) {
            mMessageList = new ArrayList<MessageEntity>();
        }
        if (mMessageList.size() == 0) {
            MessageEntity customerMessage = new MessageEntity();
            customerMessage.setFemalename(customer());
            customerMessage.setIcon(noImage());
            MessageEntity notificationMessage = new MessageEntity();
            notificationMessage.setFemalename(notification());
            notificationMessage.setIcon(noImage());
            mMessageList.add(customerMessage);
            mMessageList.add(notificationMessage);
            mMessageList.addAll(list);
        }
        mMessageList.addAll(list);
    }

    private String customer() {
        return "私信/客服";
    }

    private String notification() {
        return "官方通知";
    }

    private String noImage() {
        return "";
    }

}
