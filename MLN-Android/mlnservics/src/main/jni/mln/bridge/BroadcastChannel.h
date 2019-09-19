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

using namespace std;

typedef void(*ON_MESSAGE_CALLBACK)(void *channel, MessageEvent *event); //定义函数指针类型

class BroadcastChannel {
    
public:
    BroadcastChannel(string name);
    ~BroadcastChannel();
    void postMessage(void *msg);
    void postMessage(string name, void *msg);
    void onMessage(ON_MESSAGE_CALLBACK callback);
    void close();
    
    void setName(string name);
    string getName();
    void setExtraData(void *extraData);
    void * getExtraData();
    
    void doAction(MessageEvent *event);
    
private:
    string var_name;
    ON_MESSAGE_CALLBACK var_callback;
    void *var_extraData;
};


#endif /* BroadcastChannel_hpp */