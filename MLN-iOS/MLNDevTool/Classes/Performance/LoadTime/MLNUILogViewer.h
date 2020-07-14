//
//  MLNUILogViewer.h
//  MLNDevTool
//
//  Created by Dongpeng Dai on 2020/7/9.
//  From: https://github.com/erkanyildiz/EYLogViewer

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLNUILogViewer : NSObject
/**
 * Adds EYLogViewer to the top window of the application.
 *
 * Please call this method at the start of main.m to catch all logs.
 */
+ (void)setup;

/**
 * Shows EYLogViewer with animation, if it is hidden.
 *
 * Three-finger swipe up gesture shows EYLogViewer also.
 */
+ (void)show;

/**
 * Hides EYLogViewer with animation, if it is visible.
 *
 * Three-finger swipe down gesture hides EYLogViewer also.
 */
+ (void)hide;

/**
 * Clears console.
 *
 * Triple-tap gesture clears console also.
 */
+ (void)clear;

+ (void)addLog:(NSString *)log;

@end

NS_ASSUME_NONNULL_END
