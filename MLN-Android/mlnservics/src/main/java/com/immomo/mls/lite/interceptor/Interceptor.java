package com.immomo.mls.lite.interceptor;

import com.immomo.mls.lite.Call;
import com.immomo.mls.lite.data.ScriptResult;
import com.immomo.mls.wrapper.ScriptBundle;

public interface Interceptor {
  ScriptResult intercept(Chain chain) throws Exception;

  interface Chain {
    ScriptBundle request();
    Call call();
    ScriptResult proceed(ScriptBundle request) throws Exception;
  }
}
