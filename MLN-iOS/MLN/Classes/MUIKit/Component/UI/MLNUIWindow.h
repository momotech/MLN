//
//  MLNUIWindow.h
//  MLNUI
//
//  Created by MoMo on 2019/8/5.
//

#import "MLNUIView.h"
#import "MLNUISafeAreaViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIWindow : MLNUIView <MLNUISafeAreaViewProtocol>

@property (nonatomic, strong) NSMutableDictionary *extraInfo;

- (BOOL)canDoLuaViewDidAppear;
- (void)doLuaViewDidAppear;
- (BOOL)canDoLuaViewDidDisappear;
- (void)doLuaViewDidDisappear;
- (void)doLuaViewDestroy;
- (void)doSizeChanged;

@end

NS_ASSUME_NONNULL_END
