//
//  ArgoKitDefinitions.h
//  Pods
//
//  Created by Dongpeng Dai on 2020/8/28.
//

#ifndef ArgoKitDefinitions_h
#define ArgoKitDefinitions_h

#import <Foundation/Foundation.h>

#define ArgoKitInstance MLNUIKitInstance
#define ArgoKitInstanceHandlersManager MLNUIKitInstanceHandlersManager
#define ArgoExportProtocol MLNUIExportProtocol

extern NSString *const kArgoListenerArrayPlaceHolder;
extern NSString *const kArgoListenerArrayPlaceHolder_SUPER_IS_2D;
extern NSString *const kArgoListenALL;

// key of change
extern NSString *const kArgoListenerChangedObject;
extern NSString *const kArgoListenerChangedKey;
extern NSString *const kArgoListenerContext;
extern NSString *const kArgoListenerWrapper;
extern NSString *const kArgoListenerCallCountKey;

//extern NSString const *const kArgoListener2DArray;
extern NSString *const kArgoConstString_Dot;

typedef NS_ENUM(NSUInteger, ArgoWatchContext) {
    ArgoWatchContext_Native,
    ArgoWatchContext_Lua
};

#endif /* ArgoKitDefinitions_h */
