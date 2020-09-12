//
//  ArgoViewModelProtocol.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/9/7.
//

#ifndef ArgoViewModelProtocol_h
#define ArgoViewModelProtocol_h

@protocol ArgoViewModelProtocol <NSObject>
+ (NSString *)modelKey;
+ (NSString *)entryFileName;
+ (NSString *)bundleName;
@end

#endif /* ArgoViewModelProtocol_h */
