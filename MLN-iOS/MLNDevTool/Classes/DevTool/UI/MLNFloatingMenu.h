//
//  MLNDebuggerMenu.h
//  MLN_Example
//
//  Created by MoMo on 2018/8/15.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLNFloatingMenu;
@protocol MLNFloatingMenuDelegate <NSObject>

@optional
- (UIImage *)floatingMenu:(MLNFloatingMenu *)floatingMenu imageWithName:(NSString *)name;
- (void)floatingMenu:(MLNFloatingMenu *)floatingMenu didSelectedAtIndex:(NSUInteger)index;

@end

@interface MLNFloatingMenu : UIView

@property (nonatomic, strong) NSArray<NSString *> *iconNames;
@property (nonatomic, weak) id<MLNFloatingMenuDelegate> delegate;

- (void)open;
- (void)close;

@end
