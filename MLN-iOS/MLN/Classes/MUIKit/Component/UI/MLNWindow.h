//
//  MLNWindow.h
//  MLN
//
//  Created by MoMo on 2019/8/5.
//

#import "MLNView.h"
#import "MLNSafeAreaViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNWindow : MLNView <MLNSafeAreaViewProtocol>

@property (nonatomic, strong) NSMutableDictionary *extraInfo;

- (BOOL)canDoLuaViewDidAppear;
- (void)doLuaViewDidAppear;
- (BOOL)canDoLuaViewDidDisappear;
- (void)doLuaViewDidDisappear;
- (void)doLuaViewDestroy;
- (void)doSizeChanged;

@end

NS_ASSUME_NONNULL_END
