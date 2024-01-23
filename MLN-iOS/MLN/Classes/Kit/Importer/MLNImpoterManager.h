//
//  MLNImpoterManager.h
//  MLN
//
//  Created by xue.yunqiang on 2022/4/1.
//

#import <Foundation/Foundation.h>
@class MLNKitInstance;

@protocol MLNImpoterManagerProtocol <NSObject>

@optional
- (void)importerManagerSetupError:(NSDictionary *_Nullable)info;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MLNImpoterManager : NSObject

@property (nonatomic, strong) id<MLNImpoterManagerProtocol> handle;

+ (instancetype)shared;

- (BOOL)registBridge:(NSString *)className forInstance:(MLNKitInstance *)instance;

-(void)registMLNglobalVarForInstance:(MLNKitInstance *)instance;

@end

NS_ASSUME_NONNULL_END
