//
//  MLNCanvasPath.h
//
//
//  Created by MoMo on 2019/5/20.
//

#import <Foundation/Foundation.h>
#import "MLNEntityExportProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface MLNCanvasPath : NSObject<MLNEntityExportProtocol>


@property (nonatomic, strong, readonly) UIBezierPath *bezierPath;

@end

NS_ASSUME_NONNULL_END
