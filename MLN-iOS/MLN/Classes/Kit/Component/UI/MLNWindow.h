//
//  MLNWindow.h
//  MLN
//
//  Created by MoMo on 2019/8/5.
//

#import "MLNView.h"
#import "MLNSafeAreaViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MLNWindowAppearType) {
    MLNWindowAppearTypeViewAppear = 0,
    MLNWindowAppearTypeEnterForground,
};

typedef NS_ENUM(NSInteger, MLNWindowDisappearType) {
    MLNWindowDisappearTypeViewDisappear = 0,
    MLNWindowDisappearTypeEnterBackground,
};

@interface MLNWindow : MLNView <MLNSafeAreaViewProtocol>

@property (nonatomic, strong) NSMutableDictionary *extraInfo;

- (BOOL)canDoLuaViewDidAppear;
- (void)doLuaViewDidAppear:(MLNWindowAppearType)appearType;
- (BOOL)canDoLuaViewDidDisappear;
- (void)doLuaViewDidDisappear:(MLNWindowDisappearType)disapperType;
- (void)doLuaViewDestroy;
- (void)doSizeChanged;

@end

NS_ASSUME_NONNULL_END
