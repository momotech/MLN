//
//  MLNUIExtScope.m
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/4/9.
//

#import "MLNUIExtScope.h"

void mlnui_executeCleanupBlock (__strong mlnui_cleanupBlock_t *block) {
    (*block)();
}
