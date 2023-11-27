package com.immomo.mls.lite;

import android.view.View;

import com.immomo.mlncore.MLNCore;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.fun.globals.LuaView;
import com.immomo.mls.fun.globals.UDLuaView;
import com.immomo.mls.lite.data.ScriptResult;
import com.immomo.mls.util.CompileUtils;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.wrapper.ScriptBundle;
import com.immomo.mls.wrapper.ScriptFile;

import org.luaj.vm2.Globals;

public class Exchange {
    private final Transmitter transmitter;
    private final Call call;
    private final long lua_state;
    private final EventListener eventListener;

    public Exchange(Transmitter transmitter, Call call, Globals globals, EventListener eventListener) {
        this.transmitter = transmitter;
        this.call = call;
        this.lua_state = globals.getL_State();
        this.eventListener = eventListener;
    }

    public Globals getGlobals() {
        return Globals.getGlobalsByLState(lua_state);
    }

    public View createLuaView() {
        eventListener.bridgeRegisterStart(call);
        LuaView luaView = ((UDLuaView) Globals.getGlobalsByLState(lua_state).createUserdataAndSet(UDLuaView.LUA_SINGLE_NAME, UDLuaView.LUA_CLASS_NAME)).getView();
        luaView.putExtras(call.request().getParams());
        eventListener.bridgeRegisterEnd(call);
        return luaView;
    }


    public ScriptResult.Builder loadScriptBundle(ScriptBundle request) throws ScriptLoadException {
        eventListener.scriptExecuteStart(call);
        Globals globals = Globals.getGlobalsByLState(lua_state);
        AssertUtils.assertNullForce(request);
        AssertUtils.assertNullForce(globals);
        final ScriptFile scriptFile = request.getMain();
        AssertUtils.assertNullForce(scriptFile);
        try {
            ScriptResult.Builder response = new ScriptResult.Builder()
                    .request(request);
            CompileUtils.compile(request, globals);//编译成opcode 编译失败 和执行失败 都需要抛出异常 让上层处理
            boolean executeSuccess = globals.callLoadedData();//解释器执行opcode
            if (!executeSuccess)
                throw new ScriptLoadException(globals.getState(), globals.getErrorMsg(), globals.getError());
            eventListener.scriptExecuteEnd(call);
            return response;
        } catch (ScriptLoadException e) {
//            MLNCore.hookLuaError(e, globals);
            throw e;
        }
    }

    public void bridgingInvalidateFunc(ScriptResult response) {
        LuaView view = (LuaView) response.luaRootView();
        view.setInvalidateFunc(Globals.getGlobalsByLState(lua_state).get("updateView"));
    }

    public void bridgeRegisterStart(Call call) {
        eventListener.bridgeRegisterStart(call);
    }

    public void bridgeRegisterEnd(Call call) {
        eventListener.bridgeRegisterEnd(call);
    }

    public void recycle() {
        Globals globalsByLState = Globals.getGlobalsByLState(lua_state);
        if (globalsByLState != null) {
            globalsByLState.destroy();
        }
    }

}
