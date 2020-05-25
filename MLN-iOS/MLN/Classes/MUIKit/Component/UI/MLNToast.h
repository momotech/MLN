//
//  MLNToast.h
//  
//
//  Created by MoMo on 2018/7/11.
//

#import <Foundation/Foundation.h>
#import "MLNEntityExportProtocol.h"

@interface MLNToast : NSObject <MLNEntityExportProtocol>

+ (instancetype)toastWithMessage:(NSString *)message duration:(CGFloat)duration;

@end
