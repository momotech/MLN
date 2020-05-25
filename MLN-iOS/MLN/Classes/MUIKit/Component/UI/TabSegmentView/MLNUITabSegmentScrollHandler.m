//
//  MLNUITabSegmentScrollHandler.m
//  MLNUI
//
//  Created by MoMo on 2019/1/16.
//

#import "MLNUITabSegmentScrollHandler.h"

@interface MLNUITabSegmentScrollHandler ()
@property (nonatomic) BOOL dragStart;
@end

@implementation MLNUITabSegmentScrollHandler

- (void)getScrollPageProgressWithScrollView:(UIScrollView *)scrollView leftIndex:(NSInteger *)leftIndex rightIndex:(NSInteger *)rightIndex scrollProgress:(CGFloat *)scrollProgress {
    CGFloat offSetX = scrollView.contentOffset.x;
    
    if (offSetX >= scrollView.contentSize.width-scrollView.frame.size.width) {
        NSInteger maxPageCount =  round(scrollView.contentSize.width / scrollView.frame.size.width);
        *leftIndex = *rightIndex = MAX(maxPageCount - 1, 0);
        *scrollProgress = 1.0;
    }else if (offSetX <= 0) {
        *leftIndex = *rightIndex = 0;
        *scrollProgress = 1.0;
    }else {
        CGFloat tempProgress = offSetX / scrollView.frame.size.width;
        CGFloat progress = tempProgress - floor(tempProgress);
        *leftIndex = floor(tempProgress);
        *rightIndex = ceil(tempProgress);
        *scrollProgress = progress;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.dragStart ) {
        NSInteger leftIndex = 0;
        NSInteger rightIndex = 0;
        CGFloat progress = 0;
        [self getScrollPageProgressWithScrollView:scrollView leftIndex:&leftIndex rightIndex:&rightIndex scrollProgress:&progress];
        
        if ([self.delegate respondsToSelector:@selector(scrollWithOldIndex:toIndex:progress:)]) {
            [self.delegate scrollWithOldIndex:leftIndex toIndex:rightIndex progress:progress];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.dragStart = NO;
    if ([self.delegate respondsToSelector:@selector(scrollDidFinished)]) {
        [self.delegate scrollDidFinished];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.dragStart = YES;
    if ([self.delegate respondsToSelector:@selector(scrollDidStart)]) {
        [self.delegate scrollDidStart];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.dragStart = NO;
    if ([self.delegate respondsToSelector:@selector(scrollDidFinished)]) {
        [self.delegate scrollDidFinished];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //这里很重要，快速滑动的时候，有时候会出现先触发BeginDragging，然后才触发EndDecelerating，导致明明还在拖拽，dragStart已经设为NO。所以在拖拽停止的时候，重置为YES。
    self.dragStart = decelerate;
    if ([self.delegate respondsToSelector:@selector(scrollDidEndDragging)]) {
        [self.delegate scrollDidEndDragging];
    }
}


@end
