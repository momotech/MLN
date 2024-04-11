//
//  MLNTabSegmentScrollHandler.h
//  MLN
//
//  Created by MoMo on 2019/1/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNNativeTabSegmentView;

@protocol MLNNativeTabSegmentScrollHandlerDelegate <NSObject>
- (void)scrollWithOldIndex:(NSInteger)index toIndex:(NSInteger)toIndex progress:(CGFloat)progress;
- (void)scrollDidStart;
- (void)scrollDidFinished;
- (void)scrollDidEndDragging;
@end

@interface MLNNativeTabSegmentScrollHandler : NSObject

@property (nonatomic, weak) id<MLNNativeTabSegmentScrollHandlerDelegate> delegate;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end

NS_ASSUME_NONNULL_END
