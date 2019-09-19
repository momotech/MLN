/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
//  MessageEvent.hpp
//  MMILuaDebugger_Example
//
//  Created by tamer on 2019/6/20.
//  Copyright © 2019 feng.xiaoning. All rights reserved.
//

#ifndef MessageEvent_hpp
#define MessageEvent_hpp

#include <stdio.h>
#include <map>
#include <string>
#include <iostream>

using namespace std;

class MessageEvent {

public:
    MessageEvent();
    void setType(string type);
    string getType();
    void setData(void *data);
    void * getData();
    
private:
    string var_type;
    void *var_data;
};

#endif /* MessageEvent_hpp */