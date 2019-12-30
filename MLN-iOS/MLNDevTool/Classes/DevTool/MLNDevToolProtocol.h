//
//  MLNDevToolProtocol.h
//  MLNDevTool
//
//  Created by MoMo on 2019/9/17.
//

#ifndef MLNDevToolProtocol_h
#define MLNDevToolProtocol_h

#import <MLN/MLNKit.h>

@protocol MLNDevToolProtocol <NSObject>

@property (nonatomic, assign, readonly) BOOL isUtilViewControllerShow;

+ (instancetype)getInstance;

- (void)startWithRootView:(UIView *)rootView viewController:(UIViewController<MLNViewControllerProtocol> *)viewController;
- (void)stop;

- (void)error:(NSString *)error;
- (void)log:(NSString *)log;

- (void)doLuaViewDidAppear;
- (void)doLuaViewDidDisappear;

@end

#endif /* MLNDevToolProtocol_h */
