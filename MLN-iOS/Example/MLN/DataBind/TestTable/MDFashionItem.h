// To parse this JSON:
//
//   NSError *error;
//   MDFashionItem *fashionItem = [MDFashionItem fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class MDFashionItem;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface MDFashionItem : NSObject
@property (nonatomic, copy)           NSString *productID;
@property (nonatomic, copy)           NSString *itemid;
@property (nonatomic, copy)           NSString *sellerID;
@property (nonatomic, copy)           NSString *itemtitle;
@property (nonatomic, copy)           NSString *itemshorttitle;
@property (nonatomic, copy)           NSString *itemdesc;
@property (nonatomic, copy)           NSString *itemprice;
@property (nonatomic, copy)           NSString *itemsale;
@property (nonatomic, copy)           NSString *itemsale2;
@property (nonatomic, copy)           NSString *todaysale;
@property (nonatomic, copy)           NSString *itempic;
@property (nonatomic, copy)           NSString *itempicCopy;
@property (nonatomic, copy)           NSString *fqcat;
@property (nonatomic, copy)           NSString *itemendprice;
@property (nonatomic, copy)           NSString *shoptype;
@property (nonatomic, copy)           NSString *tktype;
@property (nonatomic, copy)           NSString *tkrates;
@property (nonatomic, copy)           NSString *cuntao;
@property (nonatomic, copy)           NSString *tkmoney;
@property (nonatomic, copy)           NSString *couponurl;
@property (nonatomic, copy)           NSString *couponmoney;
@property (nonatomic, copy)           NSString *couponsurplus;
@property (nonatomic, copy)           NSString *couponreceive;
@property (nonatomic, copy)           NSString *couponreceive2;
@property (nonatomic, copy)           NSString *todaycouponreceive;
@property (nonatomic, copy)           NSString *couponnum;
@property (nonatomic, copy)           NSString *couponexplain;
@property (nonatomic, copy)           NSString *couponstarttime;
@property (nonatomic, copy)           NSString *couponendtime;
@property (nonatomic, copy)           NSString *startTime;
@property (nonatomic, copy)           NSString *endTime;
@property (nonatomic, copy)           NSString *starttime;
@property (nonatomic, nullable, copy) id isquality;
@property (nonatomic, copy)           NSString *reportStatus;
@property (nonatomic, copy)           NSString *isBrand;
@property (nonatomic, copy)           NSString *isLive;
@property (nonatomic, copy)           NSString *guideArticle;
@property (nonatomic, copy)           NSString *videoid;
@property (nonatomic, copy)           NSString *activityType;
@property (nonatomic, copy)           NSString *generalIndex;
@property (nonatomic, nullable, copy) id planlink;
@property (nonatomic, copy)           NSString *sellerName;
@property (nonatomic, copy)           NSString *userid;
@property (nonatomic, copy)           NSString *sellernick;
@property (nonatomic, copy)           NSString *shopname;
@property (nonatomic, copy)           NSString *onlineUsers;
@property (nonatomic, nullable, copy) id originalImg;
@property (nonatomic, nullable, copy) id originalArticle;
@property (nonatomic, copy)           NSString *discount;
@property (nonatomic, copy)           NSString *isExplosion;
@property (nonatomic, nullable, copy) id me;
@property (nonatomic, copy)           NSString *activityid;
@property (nonatomic, copy)           NSString *couponCondition;
@property (nonatomic, copy)           NSString *taobaoImage;
@property (nonatomic, copy)           NSString *shopid;
@property (nonatomic, copy)           NSString *sonCategory;
@property (nonatomic, copy)           NSString *downType;
@property (nonatomic, copy)           NSString *deposit;
@property (nonatomic, copy)           NSString *depositDeduct;
@property (nonatomic, copy)           NSString *ysylTljFace;
@property (nonatomic, assign)         NSInteger presaleStartTime;
@property (nonatomic, assign)         NSInteger presaleEndTime;
@property (nonatomic, assign)         NSInteger presaleTailStartTime;
@property (nonatomic, assign)         NSInteger presaleTailEndTime;
@property (nonatomic, copy)           NSString *presaleDiscountFeeText;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
@end

NS_ASSUME_NONNULL_END
