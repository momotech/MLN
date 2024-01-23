//
//  MLNStyleString.h
//  MMDebugTools-DebugManager
//
//  Created by MoMo on 2018/7/4.
//

#import <Foundation/Foundation.h>
#import "MLNTextConst.h"
#import "MLNStyleStringConst.h"
#import "MLNEntityExportProtocol.h"

@class MLNStyleElement;

typedef void(^MLNImageLoadFinishedCallback)(NSAttributedString *attributeText);

@interface MLNStyleString : NSObject<MLNEntityExportProtocol>

- (instancetype)initWithAttributedString:(NSAttributedString *)attributes;

- (void)mln_checkImageIfNeed;

@property(nonatomic,strong, readonly) NSMutableAttributedString *mutableStyledString;

@property (nonatomic, strong, readonly) NSMutableDictionary *styleElementsDictM;

@property (nonatomic, copy) MLNImageLoadFinishedCallback loadFinishedCallback;

@end
