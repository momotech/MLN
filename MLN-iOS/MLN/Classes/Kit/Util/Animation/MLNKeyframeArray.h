//
//  MLNKeyframeArray.h
//  MLN
//
//  Created by MoMo on 2019/9/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNKeyframeArray;
@protocol MLNKeyframeArrayDelegate <NSObject>

- (id)keyframeArray:(MLNKeyframeArray *)array objectAtIndex:(NSUInteger)index;

@end

@interface MLNKeyframeArray : NSArray

@property (nonatomic, weak) id<MLNKeyframeArrayDelegate> delegate;

- (instancetype)initWithCount:(NSUInteger)count delegate:(id<MLNKeyframeArrayDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
