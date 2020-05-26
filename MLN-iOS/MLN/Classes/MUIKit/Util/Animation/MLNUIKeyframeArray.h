//
//  MLNUIKeyframeArray.h
//  MLNUI
//
//  Created by MoMo on 2019/9/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNUIKeyframeArray;
@protocol MLNUIKeyframeArrayDelegate <NSObject>

- (id)keyframeArray:(MLNUIKeyframeArray *)array objectAtIndex:(NSUInteger)index;

@end

@interface MLNUIKeyframeArray : NSArray

@property (nonatomic, weak) id<MLNUIKeyframeArrayDelegate> delegate;

- (instancetype)initWithCount:(NSUInteger)count delegate:(id<MLNUIKeyframeArrayDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
