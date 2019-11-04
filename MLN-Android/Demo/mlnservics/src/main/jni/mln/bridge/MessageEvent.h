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

class MessageEvent {

public:
    enum DataType {
        DataTypeNil,
        DataTypeString,
    };
    
public:
    MessageEvent();
    
    inline void setType(std::string &type) {
        var_type = type;
    };
    inline std::string &getType() {
        return var_type;
    };
    
    inline void setStringData(std::string &data) {
        _data_type = DataTypeString;
        var_data = data;
    };
    inline std::string &getStringData() {
        return var_data;
    };
    
    inline DataType &getDataType() {
        return _data_type;
    }
    
private:
    DataType _data_type;
    std::string var_type;
    std::string var_data;
};

#endif /* MessageEvent_hpp */
