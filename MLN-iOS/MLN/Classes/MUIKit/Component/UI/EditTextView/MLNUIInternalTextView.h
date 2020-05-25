//
//  MLNUIInternalTextView.h
//
//
//  Created by MoMo on 2018/12/21.
//

#import <UIKit/UIKit.h>
#import "MLNUITextViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIInternalTextView : UIView <MLNUITextViewProtocol, UITextViewDelegate>

@property (nonatomic, weak) id<MLNUITextViewDelegate> internalTextViewDelegate;

@property(nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;
@property (nonatomic, assign) NSInteger maxBytes;
@property (nonatomic, assign) NSInteger maxLength;

@end

NS_ASSUME_NONNULL_END
