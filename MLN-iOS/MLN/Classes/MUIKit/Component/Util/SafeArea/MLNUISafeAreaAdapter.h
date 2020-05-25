//
//  MLNUISafeAreaAdapter.h
//  MLNUI
//
//  Created by MoMo on 2019/12/20.
//

#import <Foundation/Foundation.h>
#import "MLNUIEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUISafeAreaAdapter : NSObject <MLNUIEntityExportProtocol>

@property (nonatomic, assign) CGFloat insetsTop;
@property (nonatomic, assign) CGFloat insetsBottom;
@property (nonatomic, assign) CGFloat insetsLeft;
@property (nonatomic, assign) CGFloat insetsRight;

- (void)updateInsets:(void(^)(void))callback;

@end

NS_ASSUME_NONNULL_END
