#import "MDFashionItem.h"

// Shorthand for simple blocks
#define λ(decl, expr) (^(decl) { return (expr); })

// nil → NSNull conversion for JSON dictionaries
static id NSNullify(id _Nullable x) {
    return (x == nil || x == NSNull.null) ? NSNull.null : x;
}

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces

@interface MDFashionItem (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

#pragma mark - JSON serialization

MDFashionItem *_Nullable MDFashionItemFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : [MDFashionItem fromJSONDictionary:json];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

MDFashionItem *_Nullable MDFashionItemFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    return MDFashionItemFromData([json dataUsingEncoding:encoding], error);
}

NSData *_Nullable MDFashionItemToData(MDFashionItem *fashionItem, NSError **error)
{
    @try {
        id json = [fashionItem JSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSString *_Nullable MDFashionItemToJSON(MDFashionItem *fashionItem, NSStringEncoding encoding, NSError **error)
{
    NSData *data = MDFashionItemToData(fashionItem, error);
    return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
}

@implementation MDFashionItem
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"product_id": @"productID",
        @"itemid": @"itemid",
        @"seller_id": @"sellerID",
        @"itemtitle": @"itemtitle",
        @"itemshorttitle": @"itemshorttitle",
        @"itemdesc": @"itemdesc",
        @"itemprice": @"itemprice",
        @"itemsale": @"itemsale",
        @"itemsale2": @"itemsale2",
        @"todaysale": @"todaysale",
        @"itempic": @"itempic",
        @"itempic_copy": @"itempicCopy",
        @"fqcat": @"fqcat",
        @"itemendprice": @"itemendprice",
        @"shoptype": @"shoptype",
        @"tktype": @"tktype",
        @"tkrates": @"tkrates",
        @"cuntao": @"cuntao",
        @"tkmoney": @"tkmoney",
        @"couponurl": @"couponurl",
        @"couponmoney": @"couponmoney",
        @"couponsurplus": @"couponsurplus",
        @"couponreceive": @"couponreceive",
        @"couponreceive2": @"couponreceive2",
        @"todaycouponreceive": @"todaycouponreceive",
        @"couponnum": @"couponnum",
        @"couponexplain": @"couponexplain",
        @"couponstarttime": @"couponstarttime",
        @"couponendtime": @"couponendtime",
        @"start_time": @"startTime",
        @"end_time": @"endTime",
        @"starttime": @"starttime",
        @"isquality": @"isquality",
        @"report_status": @"reportStatus",
        @"is_brand": @"isBrand",
        @"is_live": @"isLive",
        @"guide_article": @"guideArticle",
        @"videoid": @"videoid",
        @"activity_type": @"activityType",
        @"general_index": @"generalIndex",
        @"planlink": @"planlink",
        @"seller_name": @"sellerName",
        @"userid": @"userid",
        @"sellernick": @"sellernick",
        @"shopname": @"shopname",
        @"online_users": @"onlineUsers",
        @"original_img": @"originalImg",
        @"original_article": @"originalArticle",
        @"discount": @"discount",
        @"is_explosion": @"isExplosion",
        @"me": @"me",
        @"activityid": @"activityid",
        @"coupon_condition": @"couponCondition",
        @"taobao_image": @"taobaoImage",
        @"shopid": @"shopid",
        @"son_category": @"sonCategory",
        @"down_type": @"downType",
        @"deposit": @"deposit",
        @"deposit_deduct": @"depositDeduct",
        @"ysyl_tlj_face": @"ysylTljFace",
        @"presale_start_time": @"presaleStartTime",
        @"presale_end_time": @"presaleEndTime",
        @"presale_tail_start_time": @"presaleTailStartTime",
        @"presale_tail_end_time": @"presaleTailEndTime",
        @"presale_discount_fee_text": @"presaleDiscountFeeText",
    };
}

+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error
{
    return MDFashionItemFromData(data, error);
}

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    return MDFashionItemFromJSON(json, encoding, error);
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[MDFashionItem alloc] initWithJSONDictionary:dict] : nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    id resolved = MDFashionItem.properties[key];
    if (resolved) [super setValue:value forKey:resolved];
}

- (NSDictionary *)JSONDictionary
{
    id dict = [[self dictionaryWithValuesForKeys:MDFashionItem.properties.allValues] mutableCopy];

    // Rewrite property names that differ in JSON
    for (id jsonName in MDFashionItem.properties) {
        id propertyName = MDFashionItem.properties[jsonName];
        if (![jsonName isEqualToString:propertyName]) {
            dict[jsonName] = dict[propertyName];
            [dict removeObjectForKey:propertyName];
        }
    }

    return dict;
}

- (NSData *_Nullable)toData:(NSError *_Nullable *)error
{
    return MDFashionItemToData(self, error);
}

- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    return MDFashionItemToJSON(self, encoding, error);
}
@end

NS_ASSUME_NONNULL_END
