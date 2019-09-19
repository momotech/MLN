//
//  MLNTabSegmentViewDelegate.h
//  MLN
//
//  Created by MoMo on 2019/1/28.
//

#ifndef MLNTabSegmentViewDelegate_h
#define MLNTabSegmentViewDelegate_h

@class MLNTabSegmentView;
@protocol MLNTabSegmentViewDelegate <NSObject>

@optional
- (BOOL)segmentView:(MLNTabSegmentView *)segmentView shouldScrollToIndex:(NSInteger)toIndex;
- (NSInteger)segmentView:(MLNTabSegmentView *)segmentView correctIndexWithToIndex:(NSInteger)toIndex;

@end

#endif /* MLNTabSegmentViewDelegate_h */
