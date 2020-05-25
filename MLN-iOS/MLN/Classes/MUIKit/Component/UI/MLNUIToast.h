//
//  MLNUIToast.h
//  
//
//  Created by MoMo on 2018/7/11.
//

#import <Foundation/Foundation.h>
#import "MLNUIEntityExportProtocol.h"

@interface MLNUIToast : NSObject <MLNUIEntityExportProtocol>

+ (instancetype)toastWithMessage:(NSString *)message duration:(CGFloat)duration;

@end
