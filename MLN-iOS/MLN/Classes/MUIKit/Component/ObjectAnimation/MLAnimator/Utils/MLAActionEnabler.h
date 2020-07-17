//
//  MLAActionEnabler.hpp
//  MLAnimator
//
//  Created by momo783 on 2020/6/10.
//  Copyright © 2020 Boztrail. All rights reserved.
//

#ifndef MLAActionEnabler_hpp
#define MLAActionEnabler_hpp

#import <QuartzCore/CATransaction.h>
#include "Defines.h"

ANIMATOR_NAMESPACE_BEGIN

class ActionEnabler {
private:
  BOOL state;
    
public:
    ActionEnabler() ANIMATOR_NOTHROW
    {
        state = [CATransaction disableActions];
        [CATransaction setDisableActions:NO];
    }
  
    ~ActionEnabler()
    {
        [CATransaction setDisableActions:state];
    }
};

ANIMATOR_NAMESPACE_END

#endif /* MLAActionEnabler_hpp */
