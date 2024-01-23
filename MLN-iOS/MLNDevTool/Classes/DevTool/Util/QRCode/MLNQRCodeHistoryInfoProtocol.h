//
//  MLNQRCodeHistoryInfoProtocol.h
//  MLNDevTool
//
//  Created by MoMo on 2019/9/14.
//

#ifndef MLNQRCodeHistoryInfoProtocol_h
#define MLNQRCodeHistoryInfoProtocol_h
#import <Foundation/Foundation.h>

@protocol MLNQRCodeHistoryInfoProtocol <NSObject, NSCoding>

@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *iconName;

@end

#endif /* MLNQRCodeHistoryInfoProtocol_h */
