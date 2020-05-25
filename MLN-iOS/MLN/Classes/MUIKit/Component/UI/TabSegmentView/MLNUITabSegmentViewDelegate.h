//
//  MLNUITabSegmentViewDelegate.h
//  MLNUI
//
//  Created by MoMo on 2019/1/28.
//

#ifndef MLNUITabSegmentViewDelegate_h
#define MLNUITabSegmentViewDelegate_h

@class MLNUITabSegmentView;
@protocol MLNUITabSegmentViewDelegate <NSObject>

@optional
- (BOOL)segmentView:(MLNUITabSegmentView *)segmentView shouldScrollToIndex:(NSInteger)toIndex;
- (NSInteger)segmentView:(MLNUITabSegmentView *)segmentView correctIndexWithToIndex:(NSInteger)toIndex;

@end

#endif /* MLNUITabSegmentViewDelegate_h */
