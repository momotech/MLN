//
//  MLNLinkProtocol.h
//  MLN
//
//  Created by MOMO on 2020/5/8.
//

#ifndef MLNLinkProtocol_h
#define MLNLinkProtocol_h

typedef void(^MLNLinkCloseCallback)(NSDictionary *_Nullable param);

@class NSDictionary;
@protocol MLNLinkProtocol <NSObject>

+ (__kindof UIViewController * _Nonnull)mlnLinkCreateController:(NSDictionary *_Nullable)params closeCallback:(MLNLinkCloseCallback _Nullable)callback;

@end

#endif /* MLNLinkProtocol_h */
