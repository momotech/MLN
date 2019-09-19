//
//  MLNServerListenerProtocol.h
//  MLNDebugger
//
//  Created by MoMo on 2019/8/21.
//

#import <UIKit/UIKit.h>

#ifndef MLNServerListenerProtocol_h
#define MLNServerListenerProtocol_h


@class MLNServer;
@protocol MLNServerListenerProtocol <NSObject>

@optional
/**
 开始检查USB 服务是否可用

 @param server 服务处理
 @param port USB端口
 */
- (void)server:(MLNServer *)server beginCheckUSBReachable:(int)port;

/**
 检查USB 服务结束
 
 @param server 服务处理
 @param port USB端口
 @param isReachable 是否可用
 */
- (void)server:(MLNServer *)server endCheckUSBReachable:(int)port isReachable:(BOOL)isReachable;

/**
 对应地址端口的服务连接成功

 @param server 服务处理
 @param ip 链接地址
 @param port 端口
 */
- (void)server:(MLNServer *)server onConnected:(NSString *)ip port:(int)port;

/**
 对应地址端口的服务连接断开或连接失败

 @param server 服务处理
 @param ip 链接地址
 @param port 端口
 */
- (void)server:(MLNServer *)server onDisconnected:(NSString *)ip port:(int)port error:(NSError *)error;

/**
 正在同步设备信息

 @param server 服务处理
 @param ip 链接地址
 @param port 端口
 */
- (void)server:(MLNServer *)server onSyncDeviceInfo:(NSString *)ip port:(int)port;

/**
 收到消息

 @param server 服务处理
 @param message 消息
 */
- (void)server:(MLNServer *)server onMessage:(id)message;

@end

#endif /* MLNServerListenerProtocol_h */
