//
//  MLNUISnapshotManager.m
//
//
//  Created by MoMo on 2019/3/9.
//

#import "MLNUISnapshotManager.h"

@implementation MLNUISnapshotManager

+ (UIImage *)mln_captureNormalView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width, view.frame.size.height), NO, [UIScreen mainScreen].scale);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [view.layer renderInContext:context];
    view.layer.contents = nil;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)mln_captureScrollView:(UIScrollView *)scrollView
{
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, YES, [UIScreen mainScreen].scale);
    CGPoint savedContentOffset = scrollView.contentOffset;
    CGRect savedFrame = scrollView.frame;
    scrollView.contentOffset = CGPointZero;
    scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
    [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    scrollView.contentOffset = savedContentOffset;
    scrollView.frame = savedFrame;
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - 文件保存

+ (NSString *)mln_image:(UIImage *)image saveWithFileName:(NSString *)fileName
{
    NSString *tempPngDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [tempPngDir stringByAppendingPathComponent:@"MMILuaTempImage"];
    BOOL isDirectory = NO;
    BOOL isDirectoryExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if (!(isDirectoryExist && isDirectory)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        return nil;
    }
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    BOOL bSaveResult = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    return bSaveResult? filePath : nil;
}

@end
