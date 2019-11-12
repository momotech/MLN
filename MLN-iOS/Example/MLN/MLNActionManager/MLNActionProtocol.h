//
//  MLNActionProtocol.h
//  MMLNua
//
//  Created by MOMO on 2019/11/2.
//  Copyright © 2019年 MOMO. All rights reserved.
//

#ifndef MLNActionPluginProtocol_h
#define MLNActionPluginProtocol_h

@class MLNActionItem;

@protocol MLNActionProtocol <NSObject>

@required
+ (void)mln_gotoWithActionItem:(MLNActionItem *)actionItem;

@end

#endif /* MLNActionProtocol_h */
