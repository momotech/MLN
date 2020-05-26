//
//  MLNUITabSegmentScrollHandler.h
//  MLNUI
//
//  Created by MoMo on 2019/1/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNUITabSegmentView;

@protocol MLNUITabSegmentScrollHandlerDelegate <NSObject>
- (void)scrollWithOldIndex:(NSInteger)index toIndex:(NSInteger)toIndex progress:(CGFloat)progress;
- (void)scrollDidStart;
- (void)scrollDidFinished;
- (void)scrollDidEndDragging;
@end

@interface MLNUITabSegmentScrollHandler : NSObject

@property (nonatomic, weak) id<MLNUITabSegmentScrollHandlerDelegate> delegate;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end

NS_ASSUME_NONNULL_END
