//
//  ArgoListenerToken.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/8/27.
//

#import <Foundation/Foundation.h>
#import "ArgoListenerProtocol.h"
#import "ArgoListenerWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArgoListenerToken : NSObject <ArgoListenerToken>
//@property (nonatomic, strong) NSArray <ArgoListenerWrapper *> *wrappers;

@property (nonatomic, weak) id<ArgoListenerProtocol>observedObject;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, unsafe_unretained) id block;
@property (nonatomic, assign) NSInteger tokenID;

@end

NS_ASSUME_NONNULL_END
