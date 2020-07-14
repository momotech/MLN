//
//  MLNUIFPSStatus.h
//  MLNDevTool
//
//  Created by Dongpeng Dai on 2020/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIFPSStatus : NSObject

@property (nonatomic,strong)UILabel *fpsLabel;

+ (MLNUIFPSStatus *)sharedInstance;

- (void)open;
- (void)openWithHandler:(void (^)(NSInteger fpsValue))handler;
- (void)close;

@end
NS_ASSUME_NONNULL_END
