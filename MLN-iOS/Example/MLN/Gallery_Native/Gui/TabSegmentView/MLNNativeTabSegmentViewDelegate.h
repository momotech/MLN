//
//  MLNNativeTabSegmentViewDelegate.h
//  MLN
//
//  Created by MoMo on 2019/1/28.
//

#ifndef MLNNativeTabSegmentViewDelegate_h
#define MLNNativeTabSegmentViewDelegate_h

@class MLNNativeTabSegmentView;
@protocol MLNNativeTabSegmentViewDelegate <NSObject>

@optional
- (BOOL)segmentView:(MLNNativeTabSegmentView *)segmentView shouldScrollToIndex:(NSInteger)toIndex;
- (NSInteger)segmentView:(MLNNativeTabSegmentView *)segmentView correctIndexWithToIndex:(NSInteger)toIndex;

@end

#endif /* MLNNativeTabSegmentViewDelegate_h */
