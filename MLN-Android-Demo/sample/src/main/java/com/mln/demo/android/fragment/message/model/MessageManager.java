package com.mln.demo.android.fragment.message.model;

import android.content.Context;
import android.os.Handler;
import android.os.Message;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class MessageManager {
    private Context mContext;
    private Handler mHandler;
    private MessageParseThread mThread;

    private class MessageParseThread extends Thread {

        public void setParseStyle(int parseStyle) {
            mParseStyle = parseStyle;
        }

        private int mParseStyle;

        public MessageParseThread() {
        }

        public MessageParseThread(int parseStyle) {
            mParseStyle = parseStyle;
        }

        @Override
        public void run() {
            Message message = Message.obtain();
            message.obj = messageEntities();
            message.what = mParseStyle;
            mHandler.sendMessageDelayed(message, 500);
        }
    }

    public MessageManager(Context context) {
         this(context, null);
    }

    public MessageManager(Context context, Handler handler) {
        mHandler = handler;
        mContext = context;
    }

    public void fetchMessageDataAsync() {
        new MessageParseThread(1).start();
    }

    public void fetchMoreMessageDataAsync() {
        new MessageParseThread(2).start();
    }

    public List<MessageEntity> messageEntities() {
        List<MessageEntity> list = new ArrayList<>();

        deserialize(list);

        return list;
    }

    private void deserialize(List<MessageEntity> list) {
        String res = null;
        try {
            res = jsonToString();
        } catch (IOException e) {
            e.printStackTrace();
        }
        if (res != null && !"".equals(res)) {
            try {
                jsonObjectToModelList(list, res);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    private void jsonObjectToModelList(List<MessageEntity> list, String res) throws JSONException {
        JSONObject obj = new JSONObject(res);
        if (obj != null && !"".equals(obj)) {
            JSONObject restult = obj.getJSONObject(getResultArrayName());
            JSONArray data = restult.getJSONArray(getDataArrayName());
            if (data != null && data.length() > 0) {
                for (int i = 0; i < data.length(); i++) {
                    JSONObject item = data.getJSONObject(i);
                    MessageEntity messageEntity = new MessageEntity();
                    messageEntity.setFemalename(item.getString(getFemaleName()));
                    messageEntity.setIcon(item.getString(getIcon()));
                    list.add(messageEntity);
                }
            }
        }
    }

    private String jsonToString() throws IOException {
        return new String(getJsonBytes(), "utf8");
    }

    private byte[] getJsonBytes() throws IOException {
        InputStream is;
        is = mContext.getAssets().open(getJsonFileName());
        int length = is.available();
        byte[] buffer = new byte[length];
        is.read(buffer);
        return buffer;
    }

    private String getResultArrayName() {
        return "result";
    }
    private String getDataArrayName() {
        return "data";
    }

    private String getIcon() {
        return "icon";
    }

    private String getFemaleName() {
        return "title";
    }

    private String getJsonFileName() {
        return "message.json";
    }

}
