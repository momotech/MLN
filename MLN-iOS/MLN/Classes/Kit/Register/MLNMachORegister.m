//
//  MLNMachORegister.m
//  MLN
//
//  Created by xue.yunqiang on 2022/4/7.
//

#import "MLNMachORegister.h"
#import <dlfcn.h>
#import <mach-o/getsect.h>

@interface MLNMachORegister()

@property (nonatomic, strong)NSMutableDictionary <NSString *, NSMutableSet *>* multiInfo;

@property (nonatomic, strong)dispatch_semaphore_t   multiLcok;

@end

@implementation MLNMachORegister

+ (instancetype)shareRegister {
    static MLNMachORegister *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MLNMachORegister new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _multiLcok = dispatch_semaphore_create(1);
        _multiInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSSet * __nullable)shareStringSetWithKey:(NSString *)key {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self prepareMultiData];
    });
    
    if (!key) {
        return nil;
    }
    
    dispatch_semaphore_wait(_multiLcok, DISPATCH_TIME_FOREVER);
    NSMutableSet *set = [_multiInfo objectForKey:key];
    dispatch_semaphore_signal(_multiLcok);
    
    if (set) {
        return [set copy];
    }
    return nil;
}

- (void)removeValueSetWithKey:(NSString *)key {
    if (!key) {
        return;
    }
    
    dispatch_semaphore_wait(_multiLcok, DISPATCH_TIME_FOREVER);
    [_multiInfo removeObjectForKey:key];
    dispatch_semaphore_signal(_multiLcok);
}

#pragma mark - marh o

#ifdef __LP64__
typedef uint64_t MarchORegisterValue;
typedef struct section_64 MarchORegisterSection;
#define MachOGetSectByNameFromHeader getsectbynamefromheader_64
#else
typedef uint32_t MarchORegisterValue;
typedef struct section MarchORegisterSection;
#define MachOGetSectByNameFromHeader getsectbynamefromheader
#endif

void __machORegisterEmptyFouncation(void){
    // 空实现，为拿到当前image的Dl_info
}

- (void)prepareMultiData {
    _multiInfo = [NSMutableDictionary dictionaryWithCapacity:512];
    
    Dl_info info;
    dladdr((const void*)&__machORegisterEmptyFouncation, &info);

    const MarchORegisterValue   mach_header = (MarchORegisterValue)info.dli_fbase;
    const MarchORegisterSection *section = MachOGetSectByNameFromHeader((void *)mach_header, "__DATA", "mln_mach_o_kvset");
    
    if (section != NULL) {
        int addrOffset = sizeof(struct MLNMachORegisterKV);
        
        for (MarchORegisterValue addr = section->offset; addr < section->offset + section->size; addr += addrOffset) {
            struct MLNMachORegisterKV entry = *(struct MLNMachORegisterKV *)(mach_header + addr);
            
            if (entry.key && entry.value) {
                NSString *key = [NSString stringWithCString:entry.key encoding:NSUTF8StringEncoding];
                NSString *value = [NSString stringWithCString:entry.value encoding:NSUTF8StringEncoding];
                if (!key || !value) {
                    continue;
                }
                
                NSMutableSet *set = [_multiInfo objectForKey:key];
                if (!set) {
                    set = [NSMutableSet setWithCapacity:126];
                    [_multiInfo setObject:set forKey:key];
                }
                [set addObject:value];
    
#ifdef DEBUG
                if (_enableLog) {
                    NSLog(@"【MachORegister K-VSet】key: %@ - value:%@", key, value);
                }
#endif
            }
        }
    }
}

@end
