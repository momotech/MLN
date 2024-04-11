//
//  MLNTerminal.h
//  MLN
//
//  Created by MoMo on 2018/9/5.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MLNConsoleStatusClose = 0,
    MLNConsoleStatusNormal,
    MLNConsoleStatusFullScreen,
} MLNConsoleStatus;

@interface MLNConsole : UIView

@property (nonatomic, assign, readonly) MLNConsoleStatus status;
- (void)printToConsole:(NSString *)msg;
- (void)printErrorToConsole:(NSString *)msg;
- (void)clean;

@end

