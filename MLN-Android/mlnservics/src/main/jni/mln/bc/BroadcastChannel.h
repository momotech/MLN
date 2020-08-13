/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
//  BroadcastChannel.hpp
//  MMILuaDebugger_Example
//
//  Created by tamer on 2019/6/20.
//  Copyright © 2019 feng.xiaoning. All rights reserved.
//

#ifndef BroadcastChannel_hpp
#define BroadcastChannel_hpp

#include <stdio.h>
#include <map>
#include <string>
#include <iostream>
#include "MessageEvent.h"

typedef void(*ON_MESSAGE_CALLBACK)(void *channel, MessageEvent *event); //定义函数指针类型

class BroadcastChannel {
    
public:
    BroadcastChannel(std::string name);
    ~BroadcastChannel();
    void postMessage(std::string msg);
    void postMessage(std::string name, std::string msg);

    void postStickyMessage(std::string msg);
    void postStickyMessage(std::string name, std::string msg);
    void removeStickyMessage();

    void onMessage(ON_MESSAGE_CALLBACK callback);
    void close();
    
    void setName(std::string name);
    std::string getName();
    void setExtraData(void *extraData);
    void * getExtraData();
    
    void doAction(MessageEvent *event);
    
private:
    std::string var_name;
    ON_MESSAGE_CALLBACK var_callback;
    void *var_extraData;
    void updateCachedEvents(MessageEvent *newEvent);
    std::vector<MessageEvent *> &cacheEventsWithChannelName(std::string name);
};


#endif /* BroadcastChannel_hpp */