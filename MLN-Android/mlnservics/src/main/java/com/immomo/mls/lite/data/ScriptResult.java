package com.immomo.mls.lite.data;

import android.view.View;

import androidx.annotation.Nullable;

import com.immomo.mls.wrapper.ScriptBundle;

/**
 * lua执行结果包装类
 */
public class ScriptResult {
    final View luaRootView;
    final ScriptBundle request;

    public ScriptResult(Builder builder) {
        this.request = builder.request;
        this.luaRootView = builder.luaRootView;
    }

    public ScriptBundle request() {
        return request;
    }

    public View luaRootView() {
        return luaRootView;
    }

    public Builder newBuilder() {
        return new Builder(this);
    }

    public static class Builder {
        @Nullable
        ScriptBundle request;
        View luaRootView;

        public Builder() {
        }

        public Builder(ScriptResult result) {
            this.request = result.request;
            this.luaRootView = result.luaRootView;
        }

        public Builder request(ScriptBundle request) {
            this.request = request;
            return this;
        }

        public Builder luaRootView(View luaRootView) {
            this.luaRootView = luaRootView;
            return this;
        }

        public ScriptResult build() {
            if (request == null) throw new IllegalStateException("request == null");
            return new ScriptResult(this);
        }
    }

}
