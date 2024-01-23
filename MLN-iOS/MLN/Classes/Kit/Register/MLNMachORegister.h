//
//  MLNMachORegister.h
//  MLN
//
//  Created by xue.yunqiang on 2022/4/7.
//

#import <Foundation/Foundation.h>

struct MLNMachORegisterKV {
    char * _Nullable key;
    char * _Nullable value;
};

//
// key对应value的集合
// 【注】： key允许重复，key和value不允许同时重复
// 【使用】:
//  MachORegisterK_VSet(router, AViewController)
//  MachORegisterK_VSet(router, BViewController)
#define MLNMachORegisterK_VSet(key, value) \
__attribute((used, section("__DATA, mln_mach_o_kvset"))) \
static const struct MLNMachORegisterKV ___MLNMachORegisterK_VSet_##key##value = (struct MLNMachORegisterKV){(char *)(&#key), (char *)(&#value)};

// get方法
#define MLNMachORegisterGetVSetWithKey(key)    [[MLNMachORegister shareRegister] shareStringSetWithKey:key];

NS_ASSUME_NONNULL_BEGIN

@interface MLNMachORegister : NSObject

// 是否允许打印注册日志
@property (nonatomic, assign) BOOL enableLog;

+ (instancetype)shareRegister;

/// 获取key对应的value集合
/// @param key key
- (NSSet * __nullable)shareStringSetWithKey:(NSString *)key;

/// 移除key对应的集合
- (void)removeValueSetWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
