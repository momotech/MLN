//
//  BroadcastDispatchCenter.hpp
//  MMILuaDebugger_Example
//
//  Created by tamer on 2019/6/20.
//  Copyright © 2019 feng.xiaoning. All rights reserved.
//

#ifndef BroadcastDispatchCenter_hpp
#define BroadcastDispatchCenter_hpp

#include <stdio.h>
#include <map>
#include <vector>
#include <string>
#include <iostream>
#include "MessageEvent.h"
#include "BroadcastChannel.h"
#include <pthread.h>

class BroadcastDispatchCenter {
public:
    void postMessage(BroadcastChannel *sourceChannel, MessageEvent *event);
    void join(BroadcastChannel *channel);
    void remove(BroadcastChannel *channel);
    
    static BroadcastDispatchCenter& defaultCenter() {
        static BroadcastDispatchCenter sharedInstance;
        return sharedInstance;
    };
    
private:
    std::map<std::string, std::vector<BroadcastChannel *> *> *var_channels;
    pthread_mutex_t var_mutex;
private:
    BroadcastDispatchCenter(){
        var_channels = new std::map<std::string, std::vector<BroadcastChannel *> *>();
        pthread_mutex_init(&var_mutex, NULL);
    };
    
    BroadcastDispatchCenter(const BroadcastDispatchCenter &);
    void operator=(BroadcastDispatchCenter const&);
    ~BroadcastDispatchCenter(){};
};

#endif /* BroadcastDispatchCenter_hpp */
