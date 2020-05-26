//
//  MLNUILinkProtocol.h
//  MLNUI
//
//  Created by MOMO on 2020/5/8.
//

#ifndef MLNUILinkProtocol_h
#define MLNUILinkProtocol_h

typedef void(^MLNUILinkCloseCallback)(NSDictionary *_Nullable param);

@class NSDictionary;
@protocol MLNUILinkProtocol <NSObject>

+ (__kindof UIViewController * _Nonnull)mlnLinkCreateController:(NSDictionary *_Nullable)params closeCallback:(MLNUILinkCloseCallback _Nullable)callback;

@end

#endif /* MLNUILinkProtocol_h */
