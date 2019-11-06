package com.mln.demo;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class GlobalEventManager {

    public static final String ACTION_GLOBAL_EVENT   = "com.xfy.demo.globalevent.ACTION_GLOBAL_EVENT";
    public static final String SHOW_GIFT_PANEL = "NTF_ORDER_ROOM_SHOW_GIFT_PANEL";
    public static final String KEY_EVENT_NAME        = "event_name";
    public static final String KEY_DST               = "dst_l_evn";
    public static final String KEY_SRC               = "l_evn";
    public static final String KEY_EVENT_MSG         = "event_msg";
    public static final String GLOBAL_EVENT          = "global_event";

    public static final String EVN_NATIVE = "native";
    public static final String EVN_LUA = "lua";
    public static final String EVN_MK = "mk";
    public static final String EVN_WEEX = "weex";

    private static volatile GlobalEventManager instance;
    private final Map<String, List<Subscriber>> subscribers = new HashMap<>();
    private Context context;

    private GlobalEventManager() {
    }

    public static GlobalEventManager getInstance() {
        if (instance == null) {
            synchronized (GlobalEventManager.class) {
                if (instance == null) {
                    instance = new GlobalEventManager();
                }
            }
        }
        return instance;
    }

    public void init(@NonNull Context context) {
        this.context = context.getApplicationContext();
        BroadcastHelper.registerBroadcast(this.context, new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                Event event = intent.getParcelableExtra(GLOBAL_EVENT);
                if (event != null) {
                    if (event.dsts != null) {
                        for (String dst : event.dsts) {
                            List<Subscriber> subs = subscribers.get(dst);
                            if (subs != null) {
                                for (Subscriber sub : subs) {
                                    sub.onGlobalEventReceived(event);
                                }
                            }
                        }
                    } else {
                        for (Map.Entry entry : subscribers.entrySet()) {
                            List<Subscriber> subs = (List) entry.getValue();
                            if (subs != null) {
                                for (Subscriber sub : subs) {
                                    sub.onGlobalEventReceived(event);
                                }
                            }
                        }
                    }
                }
            }
        }, ACTION_GLOBAL_EVENT);
    }

    public synchronized void register(@NonNull Subscriber subscriber, @NonNull String dst) {
        List<Subscriber> sub = subscribers.get(dst);
        if (sub == null) {
            sub = new LinkedList<>();
            subscribers.put(dst, sub);
        }
        if (!sub.contains(subscriber)) {
            sub.add(subscriber);
        }
    }

    public synchronized void unregister(@NonNull Subscriber subscriber, @NonNull String dst) {
        List<Subscriber> sub = subscribers.get(dst);
        if (sub != null) {
            sub.remove(subscriber);
            if (sub.isEmpty()) {
                subscribers.remove(dst);
            }
        }
    }

    public synchronized void unregister(@NonNull String dst) {
        List<Subscriber> sub = subscribers.remove(dst);
        if (sub != null) {
            sub.clear();
        }
    }

    public synchronized void sendEvent(@NonNull Event event) {
        event.check();
        Intent intent = new Intent(GlobalEventManager.ACTION_GLOBAL_EVENT);
        intent.putExtra(GLOBAL_EVENT, event);
        BroadcastHelper.sendBroadcast(context, intent);
    }

    public synchronized void clear(@NonNull String... dsts) {
        for (String dst : dsts) {
            subscribers.remove(dst);
        }
    }

    public synchronized void clearAll() {
        subscribers.clear();
    }


    public static class Event implements Parcelable {
        /**
         * 事件名称，由业务自行筛选
         */
        private String name;
        /**
         * 事件目的环境，第一优先筛选
         * 已有环境：
         * native
         */
        private String[] dsts;
        /**
         * 事件发出地
         */
        private String src;
        /**
         * 事件具体信息
         */
        private Map<String, Object> msg;

        public Event(@NonNull JSONObject json) {
            name = (String) json.get(KEY_EVENT_NAME);
            dsts = ((String) json.get(KEY_DST)).split("\\|");
            msg = (Map) json.get(KEY_EVENT_MSG);
            src = (String) json.get(KEY_SRC);
        }

        public Event(@NonNull String name) {
            this.name = name;
        }

        public Event dst(@NonNull String... dsts) {
            this.dsts = dsts;
            return this;
        }

        public Event src(@NonNull String src) {
            this.src = src;
            return this;
        }

        public Event msg(@Nullable Map<String, Object> msg) {
            this.msg = msg;
            return this;
        }

        public Event msg(@Nullable String msg) {
            if (TextUtils.isEmpty(msg)) {
                this.msg = null;
            } else {
                this.msg = (Map) JSON.parse(msg);
            }
            return this;
        }

        void check() {
            if (TextUtils.isEmpty(name) || dsts == null || dsts.length == 0)
                throw new IllegalArgumentException("name dsts src cannot be empty!");
        }

        @Override
        public String toString() {
            return getObj().toString();
        }

        public Map<String, Object> toMap() {
            Map<String, Object> ret = new HashMap<>();
            ret.put(KEY_EVENT_NAME, name);
            ret.put(KEY_DST, dstToString());
            ret.put(KEY_SRC, src);
            ret.put(KEY_EVENT_MSG, msg);
            return ret;
        }

        private JSONObject getObj() {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put(KEY_EVENT_NAME, name);
            jsonObject.put(KEY_DST, dstToString());
            jsonObject.put(KEY_SRC, src);
            jsonObject.put(KEY_EVENT_MSG, msg);
            return jsonObject;
        }

        public String getResult() {
            JSONObject resultObj = new JSONObject();
            resultObj.put("result", getObj());
            return resultObj.toString();
        }

        public String getName() {
            return name;
        }

        public String[] getDsts() {
            return dsts;
        }

        public String getSrc() {
            return src;
        }

        public Map<String, Object> getMsg() {
            return msg;
        }

        protected Event(Parcel in) {
            name = in.readString();
            in.readStringArray(dsts);
            src = in.readString();
            in.readMap(msg, Map.class.getClassLoader());
        }

        public static final Creator<Event> CREATOR = new Creator<Event>() {
            @Override
            public Event createFromParcel(Parcel in) {
                return new Event(in);
            }

            @Override
            public Event[] newArray(int size) {
                return new Event[size];
            }
        };

        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeString(name);
            dest.writeStringArray(dsts);
            dest.writeString(src);
            dest.writeMap(msg);
        }

        private String dstToString() {
            if (dsts == null) {
                return "";
            }

            int length = dsts.length;
            if (length > 1) {
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < length; i++) {
                    if (i != 0) {
                        builder.append('|');
                    }
                    builder.append(dsts[i]);
                }
                return builder.toString();
            } else {
                return length > 0 ? dsts[0] : "";
            }
        }

    }

    public interface Subscriber {
        void onGlobalEventReceived(Event event);
    }

}
