//
//  MLNUIStyleString.h
//  MMDebugTools-DebugManager
//
//  Created by MoMo on 2018/7/4.
//

#import <Foundation/Foundation.h>
#import "MLNUITextConst.h"
#import "MLNUIStyleStringConst.h"
#import "MLNUIEntityExportProtocol.h"

@class MLNUIStyleElement;

typedef void(^MLNUIImageLoadFinishedCallback)(NSAttributedString *attributeText);

@interface MLNUIStyleString : NSObject<MLNUIEntityExportProtocol>

- (instancetype)initWithAttributedString:(NSAttributedString *)attributes;

- (void)mln_checkImageIfNeed;

@property(nonatomic,strong, readonly) NSMutableAttributedString *mutableStyledString;

@property (nonatomic, copy) MLNUIImageLoadFinishedCallback loadFinishedCallback;

@end
