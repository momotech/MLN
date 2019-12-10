/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
//  lua_broadcastchannel.c
//  MMILuaDebugger_Example
//
//  Created by tamer on 2019/6/21.
//  Copyright © 2019 feng.xiaoning. All rights reserved.
//

#include "lua_broadcastchannel.h"

#ifdef __cplusplus
#if __cplusplus
extern "C"{
#endif
#endif /* __cplusplus */

#include "lauxlib.h"


#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* __cplusplus */

#include "BroadcastChannel.h"


#define LUA_BROADCASTCHANNELLIBNAME "BroadcastChannel"
#define LUA_BROADCASTCHANNEMTLLIBNAME "BroadcastChannel_MT"
#define LUA_MESSAGEEVENTLIBNAME "MessageEvent"
#define LUA_MESSAGEEVENTMTLIBNAME "MessageEvent_MT"


void lua_bc_setclass(lua_State *L, const char *classname, int objidx) {
    luaL_getmetatable(L, classname);
    if (objidx < 0) objidx--;
    lua_setmetatable(L, objidx);
}

void lua_bc_newclass(lua_State *L, const char *classname, const luaL_Reg *func) {
    luaL_newmetatable(L, classname); /* mt */
    /* create __index table to place methods */
    lua_pushstring(L, "__index");    /* mt,"__index" */
    lua_newtable(L);                 /* mt,"__index",it */
    /* put class name into class metatable */
    lua_pushstring(L, "class");      /* mt,"__index",it,"class" */
    lua_pushstring(L, classname);    /* mt,"__index",it,"class",classname */
    lua_rawset(L, -3);               /* mt,"__index",it */
    /* pass all methods that start with _ to the metatable, and all others
     * to the index table */
    for (; func->name; func++) {     /* mt,"__index",it */
        lua_pushstring(L, func->name);
        lua_pushcfunction(L, func->func);
        lua_rawset(L, func->name[0] == '_' ? -5: -3);
    }
    lua_rawset(L, -3);               /* mt */
    lua_pop(L, 1);
}

void lua_bc_setcallback(lua_State *L, void *key, int callback_idx) {
    lua_checkstack(L, 4); // [ ... ]
    lua_pushvalue(L, callback_idx);// [...| func (index)| ... | func ]
    lua_pushlightuserdata(L, key); // [...| func (index)| ... | func | self ]
    lua_insert(L, -2); // [...| func (index)| ... | self | func ]
    lua_settable(L, LUA_REGISTRYINDEX); // regist[self] = func
}

void lua_bc_removecallback(lua_State *L, void *key) {
    lua_pushnil(L);
    lua_checkstack(L, 4); // [ ... ]
    lua_pushvalue(L, -1);// [...| func (index)| ... | func ]
    lua_pushlightuserdata(L, key); // [...| func (index)| ... | func | self ]
    lua_insert(L, -2); // [...| func (index)| ... | self | func ]
    lua_settable(L, LUA_REGISTRYINDEX); // regist[self] = func
}

bool lua_bc_pushcallback(lua_State *L, void *key) {
    lua_checkstack(L, 32); // [ ... ]
    lua_pushlightuserdata(L, key); // [ ... | target ]
    lua_gettable(L, LUA_REGISTRYINDEX);
    if (lua_isfunction(L, -1)) {
        return true;
    }
    return false;
}

/*-------------------------------------------------------------------------*\
 * UserData.
 \*-------------------------------------------------------------------------*/

typedef struct lua_bc_ud_channel lua_bc_ud_channel;

typedef struct lua_bc_ud_channel_ref {
    void *channel;
    lua_bc_ud_channel_ref(void *p) {
        channel = p;
    }
} lua_bc_ud_channel_ref;

typedef struct lua_bc_ud_channel_shared_ref {
    std::shared_ptr<lua_bc_ud_channel_ref> ref;
} lua_bc_ud_channel_shared_ref;

struct lua_bc_ud_channel {
    BroadcastChannel *channel;
    lua_State *L;
    lua_bc_ud_channel_shared_ref *shared_ref;
};

typedef struct lua_bc_ud_event {
    MessageEvent *event;
    lua_State *L;
} lua_bc_ud_msgevent;

/*-------------------------------------------------------------------------*\
 * Broadcast Channel.
 \*-------------------------------------------------------------------------*/
#if defined(JAVA_ENV)
extern "C" {
#include "../jinfo.h"

typedef struct ARGS {
    MessageEvent *event;
    lua_bc_ud_channel *channel;
} ARGS;

static int j_callback(lua_State *L, void *ud) {
    ARGS *args = (ARGS *) ud;
    MessageEvent *event = args->event;
    lua_bc_ud_channel *channel = args->channel;
    free(args);
    std::weak_ptr<lua_bc_ud_channel_ref> wref = channel->shared_ref->ref;
    std::shared_ptr<lua_bc_ud_channel_ref> sref = wref.lock();
    if (!sref) {
        delete event;
    } else if (L && lua_bc_pushcallback(L, channel)) {
        lua_bc_ud_msgevent *ud_msgevent = (lua_bc_ud_msgevent *) lua_newuserdata(L,
                                                                                 sizeof(lua_bc_ud_msgevent));
        ud_msgevent->event = event;
        ud_msgevent->L = L;
        lua_bc_setclass(L, LUA_MESSAGEEVENTMTLIBNAME, -1);
        int success = lua_pcall(L, 1, 1, 0);
        if (success != 0) {
            std::cout << "lua callback error!" << lua_tostring(L, -1) << std::endl;
        }
    } else {
        delete event;
    }
    return 0;
}
}
#endif

static void lua_bc_callback (void * channel, MessageEvent *event_) {
    if (!channel || !event_)
        return;
    MessageEvent *event = new MessageEvent(*event_);

#if defined(JAVA_ENV)
    BroadcastChannel *ch = (BroadcastChannel *)channel;
    lua_bc_ud_channel *ud = (lua_bc_ud_channel *)ch->getExtraData();
    if (!ud)
        return;
    JNIEnv * env;
    int need = getEnv(&env);
    if (ud->L) {
        ARGS * args = (ARGS *)malloc(sizeof(ARGS));
        args->channel = ud;
        args->event = event;
        int ret = postCallback(env, ud->L, j_callback, (void *)args);
        if (ret != 0) {
            free(args);
            delete event;
        }
    }
    if (need) detachEnv();
#else
    BroadcastChannel *ch = (BroadcastChannel *)channel;
    lua_bc_ud_channel *ud = (lua_bc_ud_channel *)ch->getExtraData();
    std::weak_ptr<lua_bc_ud_channel_ref> wref = ud->shared_ref->ref;
    dispatch_async(dispatch_get_main_queue(), ^{
        std::shared_ptr<lua_bc_ud_channel_ref> sref = wref.lock();
        if (sref) {
#if DEBUG
            std::cout << "lua : " << event->getType() << event->getStringData() << std::endl;
#endif
            lua_bc_ud_channel *ud = (lua_bc_ud_channel *)ch->getExtraData();
            if (ud != NULL && ud->L != NULL && lua_bc_pushcallback(ud->L, ud)) {
                lua_bc_ud_msgevent *ud_msgevent = (lua_bc_ud_msgevent *)lua_newuserdata(ud->L, sizeof(lua_bc_ud_msgevent));
                ud_msgevent->event = event;
                ud_msgevent->L = ud->L;
                lua_bc_setclass(ud->L, LUA_MESSAGEEVENTMTLIBNAME, -1);
                int success = lua_pcall(ud->L, 1, 1, 0);
#if DEBUG
                if (success!=0) {
                    std::cout << "lua callback error!" << lua_tostring(ud->L, -1) << std::endl;
                }
#endif
                return;
            }
        }
        delete event;
    });
#endif
}

static int lua_bc_new_channel(lua_State *L) {
    const char *name = lua_tostring(L, 1);
    lua_bc_ud_channel *ud = (lua_bc_ud_channel *)lua_newuserdata(L, sizeof(lua_bc_ud_channel));
    ud->channel = new BroadcastChannel(name);
    ud->L = L;
    ud->channel->setExtraData(ud);
    ud->shared_ref = new lua_bc_ud_channel_shared_ref;
    ud->shared_ref->ref = std::make_shared<lua_bc_ud_channel_ref>(new lua_bc_ud_channel_ref(ud));
    lua_bc_setclass(L, LUA_BROADCASTCHANNEMTLLIBNAME, -1);
    return 1;
}

static int lua_bc_channel_gc(lua_State *L) {
    lua_bc_ud_channel *ud = (lua_bc_ud_channel *)lua_touserdata(L, 1);
    BroadcastChannel *channel = ud->channel;
    ud->L = NULL;
    ud->channel = NULL;
    delete ud->shared_ref;
    lua_bc_removecallback(L, ud);
    if (channel) {
        delete channel;
    }
    return 0;
}

static int lua_bc_channel_tostring(lua_State *L) {
    lua_pushstring(L, "broadcast channel");
    return 1;
}

static int lua_bc_channel_postMessage(lua_State *L) {
    if (lua_gettop(L) == 2) {
        lua_bc_ud_channel *ud = (lua_bc_ud_channel *)lua_touserdata(L, 1);
        std::string data = lua_tostring(L, 2);
        ud->channel->postMessage(data);
    } else if(lua_gettop(L) == 3) {
        lua_bc_ud_channel *ud = (lua_bc_ud_channel *)lua_touserdata(L, 1);
        std::string name = lua_tostring(L, 2);
        std::string data = lua_tostring(L, 3);
        ud->channel->postMessage(name, data);
    }
    return 0;
}

static int lua_bc_channel_postSticky(lua_State *L) {
    if (lua_gettop(L) == 2) {
        lua_bc_ud_channel *ud = (lua_bc_ud_channel *)lua_touserdata(L, 1);
        std::string data = lua_tostring(L, 2);
        ud->channel->postStickyMessage(data);
    } else if(lua_gettop(L) == 3) {
        lua_bc_ud_channel *ud = (lua_bc_ud_channel *)lua_touserdata(L, 1);
        std::string name = lua_tostring(L, 2);
        std::string data = lua_tostring(L, 3);
        ud->channel->postStickyMessage(name, data);
    }
    return 0;
}

static int lua_bc_channel_removeSticky(lua_State *L) {
    lua_bc_ud_channel *ud = (lua_bc_ud_channel *)lua_touserdata(L, 1);
    if (!ud || !ud->channel) return 0;
    ud->channel->removeStickyMessage();
    return 0;
}

static int lua_bc_channel_onMessage(lua_State *L) {
    lua_bc_ud_channel *ud = (lua_bc_ud_channel *)lua_touserdata(L, 1);
    lua_bc_setcallback(L, ud, 2);
    ud->channel->onMessage(&lua_bc_callback);
    return 0;
}

static int lua_bc_channel_close(lua_State *L) {
    lua_bc_ud_channel *ud = (lua_bc_ud_channel *)lua_touserdata(L, 1);
    ud->channel->close();
    lua_bc_removecallback(L, ud);
    return 0;
}

static int lua_bc_channel_getName(lua_State *L) {
    lua_bc_ud_channel *ud = (lua_bc_ud_channel *)lua_touserdata(L, 1);
    const char *name = ud->channel->getName().c_str();
    lua_pushstring(L, name);
    return 1;
}

/* }====================================================== */

static const luaL_Reg bc_channel_funcs[] = {
        {"postMessage", lua_bc_channel_postMessage},
        {"postSticky", lua_bc_channel_postSticky},
        {"removeSticky", lua_bc_channel_removeSticky},
        {"onMessage", lua_bc_channel_onMessage},
        {"close", lua_bc_channel_close},
        {"getName", lua_bc_channel_getName},
        {"__gc",        lua_bc_channel_gc},
        {"__tostring",  lua_bc_channel_tostring},
        {NULL, NULL}
};

/*-------------------------------------------------------------------------*\
 * Message Event.
 \*-------------------------------------------------------------------------*/

static int lua_bc_new_messageEvent(lua_State *L) {
    lua_bc_ud_msgevent *ud = (lua_bc_ud_msgevent *)lua_newuserdata(L, sizeof(lua_bc_ud_msgevent));
    ud->event = new MessageEvent();
    ud->L = L;
    lua_bc_setclass(L, LUA_MESSAGEEVENTMTLIBNAME, -1);
    return 1;
}

static int lua_bc_messageEvent_gc(lua_State *L) {
    lua_bc_ud_msgevent *ud = (lua_bc_ud_msgevent *)lua_touserdata(L, 1);
    MessageEvent *msgEvent = ud->event;
    ud->event = NULL;
    ud->L = NULL;
    if (msgEvent) {
        delete msgEvent;
    }
    return 0;
}

static int lua_bc_messageEvent_tostring(lua_State *L) {
    lua_bc_ud_msgevent *ud = (lua_bc_ud_msgevent *)lua_touserdata(L, 1);
    std::string data = ud->event->getStringData();
    if (data.empty()) {
        data = "null";
    }
    std::string msg = "<MessageEvent" + std::to_string((long)ud) + " type:" + ud->event->getType() + ", data:"+ data + " >";
    lua_pushstring(L, msg.c_str());
    return 1;
}

static int lua_bc_msgevent_settype(lua_State *L) {
    lua_bc_ud_msgevent *ud = (lua_bc_ud_msgevent *)lua_touserdata(L, 1);
    std::string name = lua_tostring(L, 2);
    ud->event->setType(name);
    return 0;
}

static int lua_bc_msgevnet_gettype(lua_State *L) {
    lua_bc_ud_msgevent *ud = (lua_bc_ud_msgevent *)lua_touserdata(L, 1);
    const char *type = ud->event->getType().c_str();
    lua_pushstring(L, type);
    return 1;
}

static int lua_bc_msgevent_setdata(lua_State *L) {
    lua_bc_ud_msgevent *ud = (lua_bc_ud_msgevent *)lua_touserdata(L, 1);
    std::string name = lua_tostring(L, 2);
    ud->event->setStringData(name);
    return 0;
}

static int lua_bc_msgevnet_getdata(lua_State *L) {
    lua_bc_ud_msgevent *ud = (lua_bc_ud_msgevent *)lua_touserdata(L, 1);
    if (ud->event->getStringData().empty()) {
        lua_pushnil(L);
    } else {
        lua_pushstring(L, ud->event->getStringData().c_str());
    }
    return 1;
}

/* }====================================================== */

static const luaL_Reg bc_msgevent_funcs[] = {
        {"setType", lua_bc_msgevent_settype},
        {"getType", lua_bc_msgevnet_gettype},
        {"setData", lua_bc_msgevent_setdata},
        {"getData", lua_bc_msgevnet_getdata},
        {"__gc",        lua_bc_messageEvent_gc},
        {"__tostring",  lua_bc_messageEvent_tostring},
        {NULL, NULL}
};

/*-------------------------------------------------------------------------*\
 * Setup basic stuff.
 \*-------------------------------------------------------------------------*/

LUABROADCASTCHANNEL_API int luaopen_broadcastchannel(lua_State *L) {
    // constructor
    lua_register(L, LUA_BROADCASTCHANNELLIBNAME, lua_bc_new_channel);
    lua_bc_newclass(L, LUA_BROADCASTCHANNEMTLLIBNAME, bc_channel_funcs);

    lua_register(L, LUA_MESSAGEEVENTLIBNAME, lua_bc_new_messageEvent);
    lua_bc_newclass(L, LUA_MESSAGEEVENTMTLIBNAME, bc_msgevent_funcs);
    return 1;
}

JNIEXPORT void JNICALL Java_com_immomo_mls_NativeBroadcastChannel__1openLib
(JNIEnv *env, jclass cls, jlong l) {
    luaopen_broadcastchannel((lua_State *) l);
}